# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "padded_cell"
require "minitest"
require "mocha/minitest"
require "webmock/minitest"

if defined?(PaddedCell)
  PaddedCell.coverage(:rails) do
    track "script/"
    group "Scripts", "script"
    skip "app/controllers/rails/pwa_controller.rb"
    skip "app/components"
    skip "app/views"
    skip "app/avo"
    skip "lib/tasks/annotate_rb.rake"
    minimum line: 100, branch: 100
    formats :markdown, :lcov, :json
    dir "coverage"
  end
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"

abort("The Rails environment is running in production mode!") if Rails.env.production?

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module TestSupport
  class << self
    def dynamic_calls
      Thread.current[:test_support_dynamic_calls] ||= []
    end

    def record_dynamic_call(stub_target, receiver, method_name, args, kwargs, block = nil)
      dynamic_calls << {
        target: stub_target,
        receiver: receiver,
        method_name: method_name,
        arguments: kwargs.empty? ? args : [ *args, kwargs ],
        block:
      }
    end

    def clear_dynamic_calls
      Thread.current[:test_support_dynamic_calls] = []
    end
  end

  class Matcher
    attr_reader :description

    def initialize(description, &predicate)
      @description = description
      @predicate = predicate
    end

    def matches?(actual)
      @predicate.call(actual)
    end

    def failure_message(actual)
      "expected #{actual.inspect} to #{description}"
    end

    def negated_failure_message(actual)
      "expected #{actual.inspect} not to #{description}"
    end
  end

  class EqualityMatcher < Matcher
    def initialize(expected, identity: false)
      @expected = expected
      super("equal #{expected.inspect}") { |actual| identity ? actual.equal?(expected) : actual == expected }
    end
  end

  class ComparisonMatcher < Matcher
    def initialize(operator, expected)
      super("be #{operator} #{expected.inspect}") { |actual| actual.public_send(operator, expected) }
    end
  end

  class BeMatcher < Matcher
    def initialize
      super("be truthy", &:itself)
    end

    %i[< <= > >=].each do |operator|
      define_method(operator) { |expected| ComparisonMatcher.new(operator, expected) }
    end
  end

  class IncludeMatcher < Matcher
    def initialize(expected)
      @expected = expected
      super("include #{expected.inspect}") { |actual| includes?(actual, expected) }
    end

    private

    def includes?(actual, expected)
      if expected.is_a?(Hash)
        if actual.respond_to?(:key?)
          expected.all? do |key, value|
            actual.key?(key) && value_matches?(actual[key], value)
          end
        elsif actual.respond_to?(:any?)
          actual.any? { |candidate| includes?(candidate, expected) }
        else
          false
        end
      elsif expected.is_a?(Array)
        actual && expected.all? { |value| actual.include?(value) }
      else
        actual&.include?(expected) || false
      end
    end

    def value_matches?(actual, expected)
      matcher_matches?(expected, actual)
    end

    def matcher_matches?(expected, actual)
      if expected.is_a?(Matcher)
        expected.matches?(actual)
      elsif expected.respond_to?(:to_matcher)
        Mocha::ParametersMatcher.new([ expected ]).match?([ actual ])
      else
        actual == expected
      end
    end
  end

  class CollectionMatcher < Matcher
    def initialize(expected)
      @expected = expected
      super("contain exactly #{expected.inspect}") do |actual|
        actual.size == expected.size && actual.all? { |item| expected.any? { |candidate| value_matches?(item, candidate) } }
      end
    end

    private

    def value_matches?(actual, expected)
      if expected.is_a?(Matcher)
        expected.matches?(actual)
      elsif expected.respond_to?(:to_matcher)
        Mocha::ParametersMatcher.new([ expected ]).match?([ actual ])
      else
        actual == expected
      end
    end
  end

  class PredicateMatcher < Matcher
    def initialize(method_name, expected = :__none__)
      @method_name = method_name
      @expected = expected
      description = expected == :__none__ ? "satisfy ##{method_name}?" : "satisfy ##{method_name}?(#{expected.inspect})"
      super(description) do |actual|
        result = actual.public_send(method_name)
        expected == :__none__ ? result : result == expected
      end
    end
  end

  class BlockMatcher < Matcher
    def initialize(description, &predicate)
      super(description, &predicate)
    end

    def match_block(block)
      matches?(block)
    end
  end

  class RaiseErrorMatcher < BlockMatcher
    attr_reader :error

    def initialize(error_class = Exception, message = nil, &handler)
      @error_class = error_class || Exception
      @message = message
      @handler = handler
      super("raise #{@error_class}") { |block| check(block) }
    end

    def check(block)
      raised = nil
      begin
        block.call
      rescue Exception => error # rubocop:disable Lint/RescueException
        raised = error
      end
      @error = raised
      return false unless raised && raised.is_a?(@error_class)
      return false if @message && !(@message === raised.message)

      @handler ? @handler.call(raised) : true
    end

    def matches_exception(error)
      @error = error
      return false unless error && error.is_a?(@error_class)
      return false if @message && !(@message === error.message)

      @handler ? @handler.call(error) : true
    end

    def with_handler(&handler)
      @handler = handler
      self
    end

    def and(matcher)
      CombinedMatcher.new(self, matcher)
    end
  end

  class OutputMatcher < Matcher
    attr_reader :stream

    def initialize(expected = nil, &assertion)
      @expected = expected
      @assertion = assertion
      @stream = :stdout
      super("produce #{expected.inspect}") { |value| matches_output?(value) }
    end

    def to_stdout
      @stream = :stdout
      self
    end

    def to_stderr
      @stream = :stderr
      self
    end

    def with_assertion(&assertion)
      @assertion = assertion
      self
    end

    def and(matcher)
      CombinedMatcher.new(self, matcher)
    end

    def matches_output?(value)
      return @assertion.call(value) if @assertion
      @expected ? (@expected === value) : value.empty?
    end
  end

  class ChangeMatcher < Matcher
    attr_reader :before, :after

    def initialize(receiver = nil, method_name = nil, &value_block)
      @receiver = receiver
      @method_name = method_name
      @value_block = value_block
      @expected_delta = nil
      @expected_from = :__none__
      @expected_to = :__none__
      super("change") { |block| check(block) }
    end

    def by(delta)
      @expected_delta = delta
      self
    end

    def from(value)
      @expected_from = value
      self
    end

    def to(value)
      @expected_to = value
      self
    end

    def and(matcher)
      CombinedMatcher.new(self, matcher)
    end

    def check(block)
      @before = current_value
      block.call
      @after = current_value
      matches_values?
    end

    def matches_values?
      return false if @after == @before && @expected_delta.nil? && @expected_from == :__none__ && @expected_to == :__none__
      return false if @expected_delta && (@after - @before != @expected_delta)
      return false if @expected_from != :__none__ && @before != @expected_from
      return false if @expected_to != :__none__ && @after != @expected_to

      true
    end

    private

    def current_value
      @value_block ? @value_block.call : @receiver.public_send(@method_name)
    end
  end

  class CombinedMatcher
    attr_reader :matchers

    def initialize(*matchers)
      @matchers = matchers.flatten.flat_map { |matcher| matcher.is_a?(self.class) ? matcher.matchers : matcher }
    end

    def and(matcher)
      self.class.new(*@matchers, matcher)
    end

    def matches?(actual)
      if actual.respond_to?(:call)
        changes = @matchers.grep(ChangeMatcher)
        changes.each { |change| change.instance_variable_set(:@before, change.send(:current_value)) }
        error = nil
        old_stdout, old_stderr = $stdout, $stderr
        stdout_io, stderr_io = StringIO.new, StringIO.new
        $stdout, $stderr = stdout_io, stderr_io
        begin
          actual.call
        rescue Exception => raised # rubocop:disable Lint/RescueException
          error = raised
        ensure
          stdout, stderr = stdout_io.string, stderr_io.string
          $stdout, $stderr = old_stdout, old_stderr
        end
        changes.each { |change| change.instance_variable_set(:@after, change.send(:current_value)) }

        raise error if error && !@matchers.any?(RaiseErrorMatcher)

        @matchers.all? do |matcher|
          case matcher
          when RaiseErrorMatcher
            matcher.matches_exception(error)
          when OutputMatcher
            matcher.matches_output?(matcher.stream == :stdout ? stdout : stderr)
          when ChangeMatcher
            matcher.matches_values?
          else
            matcher.matches?(actual)
          end
        end
      else
        @matchers.all? { |matcher| matcher.matches?(actual) }
      end
    end

    private

    def capture_output
      old_stdout, old_stderr = $stdout, $stderr
      stdout, stderr = StringIO.new, StringIO.new
      $stdout, $stderr = stdout, stderr
      yield
      [ stdout.string, stderr.string ]
    ensure
      $stdout, $stderr = old_stdout, old_stderr
    end
  end

  class ReceiveMatcher
    attr_reader :method_name, :arguments

    def initialize(method_name, &implementation)
      @method_name = method_name
      @arguments = nil
      @implementation = implementation
      @return_values = nil
      @yield_values = nil
      @raise_error = nil
      @call_original = false
      @count = nil
    end

    def with_implementation(&implementation)
      @implementation = implementation
      self
    end

    def with(*arguments, **keywords)
      @arguments = keywords.empty? ? arguments : [ *arguments, keywords ]
      self
    end

    def and_return(*values)
      @return_values = values
      self
    end

    def and_yield(*values)
      @yield_values = values
      self
    end

    def and_raise(error = RuntimeError, message = nil)
      @raise_error = [ error, message ]
      self
    end

    def and_call_original
      @call_original = true
      self
    end

    def once
      @count = 1
      self
    end

    def twice
      @count = 2
      self
    end

    def never
      @count = 0
      self
    end

    def install(target, expectation: false, any_instance: false, test:)
      if @implementation
        test.install_dynamic_stub(target, method_name, @implementation, any_instance: any_instance)
        return
      end

      if @call_original
        target.unstub(method_name) unless any_instance
        test.install_dynamic_stub(target, method_name, nil, any_instance: any_instance, call_original: true)
        return
      end

      object = any_instance ? target.any_instance : target
      configured = expectation ? object.expects(method_name) : object.stubs(method_name)
      configured.with(*arguments) if arguments
      configured.returns(*@return_values) if @return_values
      configured.yields(*@yield_values) if @yield_values
      configured.raises(*@raise_error) if @raise_error
      configured.calls_original if @call_original
      configured.times(@count) if @count
    end
  end

  class ReceiveMessagesMatcher
    def initialize(messages)
      @messages = messages
    end

    def install(target, expectation: false, any_instance: false, test:)
      object = any_instance ? target.any_instance : target
      (expectation ? object.expects(@messages) : object.stubs(@messages))
    end
  end

  class ReceiveMessageChainMatcher < ReceiveMatcher
    def initialize(methods)
      @methods = methods
      super(methods.first)
    end

    def install(target, expectation: false, any_instance: false, test:)
      object = any_instance ? target.any_instance : target
      child = test.mock("#{@methods.join(".")}")
      first = expectation ? object.expects(@methods.first) : object.stubs(@methods.first)
      first.returns(child)
      terminal = expectation ? child.expects(@methods.last) : child.stubs(@methods.last)
      terminal.raises(*@raise_error) if @raise_error
      terminal.returns(*@return_values) if @return_values
      terminal.yields(*@yield_values) if @yield_values
    end
  end

  class HaveReceivedMatcher
    def initialize(method_name)
      @method_name = method_name
      @arguments = nil
      @count = nil
      @verification_block = nil
    end

    def with(*arguments, **keywords)
      @arguments = keywords.empty? ? arguments : [ *arguments, keywords ]
      self
    end

    def once(&block)
      @count = 1
      @verification_block = block if block
      self
    end

    def twice(&block)
      @count = 2
      @verification_block = block if block
      self
    end

    def exactly(count)
      @count = count
      self
    end

    def times(count = nil, &block)
      @count = count if count
      @verification_block = block if block
      self
    end

    def with_verification_block(&block)
      @verification_block = block
      self
    end

    def matches?(target)
      dynamic_invocations = TestSupport.dynamic_calls.select do |call|
        call[:target].equal?(target) && call[:method_name].to_sym == @method_name.to_sym
      end
      dynamic_invocations.select! { |call| arguments_match?(call[:arguments]) } if @arguments
      invocations = dynamic_invocations.map { |call| Invocation.new(call[:arguments], call[:block]) }
      if invocations.empty?
        mockery = if target.is_a?(Mocha::Mock)
          target
        elsif target.respond_to?(:mocha)
          target.mocha(instantiate: false)
        end

        invocations = if mockery
          mockery.all_expectations.to_a.flat_map do |expectation|
            next [] unless expectation.matches_method?(@method_name)

            expectation.instance_variable_get(:@cardinality).instance_variable_get(:@invocations)
          end
        else
          []
        end
        invocations.select! { |invocation| arguments_match?(invocation.arguments) } if @arguments
      end

      return false unless count_matches?(invocations.size)
      return true unless @verification_block

      invocations.all? do |invocation|
        block = invocation.respond_to?(:block) ? invocation.block : invocation.instance_variable_get(:@block)
        @verification_block.call(*invocation.arguments, &block)
        true
      end
    end

    private

    def arguments_match?(actual)
      if @arguments.any? { |expected| !expected.is_a?(Matcher) && expected.respond_to?(:to_matcher) }
        return Mocha::ParametersMatcher.new(@arguments).match?(actual.dup)
      end

      return actual == @arguments if actual.size != @arguments.size

      actual.zip(@arguments).all? do |value, expected|
        expected.is_a?(Matcher) ? expected.matches?(value) : expected == value
      end
    end

    def count_matches?(count)
      @count ? count == @count : count.positive?
    end

    Invocation = Data.define(:arguments, :block)
  end

  class HaveBeenRequestedMatcher
    def initialize(_request = nil)
      @count = nil
    end

    def once
      @count = 1
      self
    end

    def matches?(actual)
      count = WebMock::RequestRegistry.instance.times_executed(actual.request_pattern)
      @count ? count == @count : count.positive?
    end
  end

  class Expectation
    def initialize(test, target)
      @test = test
      @target = target
    end

    def to(matcher = nil, &block)
      if block && matcher
        if matcher.respond_to?(:with_verification_block)
          matcher.with_verification_block(&block)
        elsif matcher.respond_to?(:with_handler)
          matcher.with_handler(&block)
        elsif matcher.respond_to?(:with_assertion)
          matcher.with_assertion(&block)
        end
      end
      @test.assert_test_matcher(@target, matcher)
    end

    def not_to(matcher = nil)
      @test.refute_test_matcher(@target, matcher)
    end
  end
end

module TestSupport::DSL
  def context(description, *additional, &block)
    describe(description, *additional, &block)
  end

  def let!(name, &block)
    let(name, &block)
    before { public_send(name) }
  end

  def subject(name = :subject, &block)
    let(name, &block)
  end

  def it(description = "anonymous", *_metadata, &block)
    super(description, &block)
  end
end

class ApplicationTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  extend TestSupport::DSL
  include Minitest::Spec::DSL::InstanceMethods
  include FactoryBot::Syntax::Methods
  include Devise::Test::IntegrationHelpers
  include McpRequests

  before do
    WebMock.reset!
    TestSupport.clear_dynamic_calls
  end

  after { cleanup_dynamic_stubs }

  def expect(target = nil, &block)
    TestSupport::Expectation.new(self, block || target)
  end

  def is_expected
    expect(subject)
  end

  def subject
    described_class&.new
  end

  def described_class
    self.class.ancestors.each do |ancestor|
      next unless ancestor.respond_to?(:desc)
      description = ancestor.desc
      return description if description.is_a?(Class)
    end
    nil
  end

  def eq(expected)
    TestSupport::EqualityMatcher.new(expected)
  end

  def eql(expected)
    TestSupport::Matcher.new("eql #{expected.inspect}") { |actual| actual.eql?(expected) }
  end

  def equal(expected)
    TestSupport::EqualityMatcher.new(expected, identity: true)
  end

  def be(expected = :__none__)
    return TestSupport::EqualityMatcher.new(expected, identity: true) unless expected == :__none__
    TestSupport::BeMatcher.new
  end

  def be_nil
    TestSupport::Matcher.new("be nil", &:nil?)
  end

  def be_empty
    TestSupport::Matcher.new("be empty", &:empty?)
  end

  def be_valid
    TestSupport::PredicateMatcher.new(:valid?)
  end

  def be_confirmed
    TestSupport::PredicateMatcher.new(:confirmed?)
  end

  def be_present
    TestSupport::Matcher.new("be present") { |actual| actual.present? }
  end

  def be_a(klass)
    TestSupport::Matcher.new("be a #{klass}") { |actual| actual.is_a?(klass) }
  end
  alias be_an be_a

  def be_in(values)
    TestSupport::Matcher.new("be in #{values.inspect}") { |actual| values.include?(actual) }
  end

  def include(*expected)
    expected.one? ? TestSupport::IncludeMatcher.new(expected.first) : TestSupport::IncludeMatcher.new(expected)
  end

  def contain_exactly(*expected)
    TestSupport::CollectionMatcher.new(expected.one? && expected.first.is_a?(Array) ? expected.first : expected)
  end
  alias match_array contain_exactly

  def match(expected)
    TestSupport::Matcher.new("match #{expected.inspect}") { |actual| expected === actual }
  end

  def end_with(expected)
    TestSupport::Matcher.new("end with #{expected.inspect}") { |actual| actual.end_with?(expected) }
  end

  def have_key(key)
    TestSupport::Matcher.new("have key #{key.inspect}") { |actual| actual.key?(key) }
  end

  def respond_to(*methods)
    TestSupport::Matcher.new("respond to #{methods.inspect}") { |actual| methods.all? { |method| actual.respond_to?(method) } }
  end

  def satisfy(&block)
    TestSupport::Matcher.new("satisfy predicate", &block)
  end

  def raise_error(error = Exception, message = nil, &block)
    TestSupport::RaiseErrorMatcher.new(error, message, &block)
  end

  def output(expected = nil, &block)
    TestSupport::OutputMatcher.new(expected, &block)
  end

  def change(receiver = nil, method_name = nil, &block)
    TestSupport::ChangeMatcher.new(receiver, method_name, &block)
  end

  def have_http_status(status)
    expected = if status == :success
      Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(:ok)
    elsif status.is_a?(Symbol)
      Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status)
    else
      status
    end
    TestSupport::Matcher.new("have HTTP status #{status}") { |response| response.status == expected }
  end

  def redirect_to(location)
    TestSupport::Matcher.new("redirect to #{location.inspect}") do |response|
      response.redirect? && response.location == URI.join("http://www.example.com", location.to_s).to_s
    rescue URI::InvalidURIError
      response.redirect? && response.location == location.to_s
    end
  end

  def route_to(expected)
    TestSupport::Matcher.new("route to #{expected.inspect}") do |request|
      method, path = request.first
      actual = Rails.application.routes.recognize_path(path, method: method.to_s.upcase)
      expected.all? do |key, value|
        actual_value = actual[key.to_s] || actual[key.to_sym]
        actual_value.to_s == value.to_s
      end
    rescue ActionController::RoutingError
      false
    end
  end

  def receive(method_name, &implementation)
    TestSupport::ReceiveMatcher.new(method_name, &implementation)
  end

  def receive_messages(messages)
    TestSupport::ReceiveMessagesMatcher.new(messages)
  end

  def receive_message_chain(*methods)
    TestSupport::ReceiveMessageChainMatcher.new(methods)
  end

  def allow(target)
    StubTarget.new(self, target, expectation: false)
  end

  def expect_any_instance_of(target)
    StubTarget.new(self, target, expectation: true, any_instance: true)
  end

  def allow_any_instance_of(target)
    StubTarget.new(self, target, expectation: false, any_instance: true)
  end

  def double(name = "double", **attributes)
    name = name.name if name.respond_to?(:name)
    object = mock(name)
    object.stubs(attributes) unless attributes.empty?
    object
  end
  alias instance_double double
  alias class_double double

  def have_received(method_name)
    TestSupport::HaveReceivedMatcher.new(method_name)
  end

  def have_been_requested
    TestSupport::HaveBeenRequestedMatcher.new
  end

  def assert_test_matcher(target, matcher)
    matcher = TestSupport::CombinedMatcher.new(matcher) if matcher.is_a?(TestSupport::ChangeMatcher)
    result = matcher.matches?(target)
    return assert(true) if result

    message = if matcher.respond_to?(:failure_message)
      matcher.method(:failure_message).arity.zero? ? matcher.failure_message : matcher.failure_message(target)
    else
      "expected #{target.inspect} to match"
    end
    flunk message
  end

  def refute_test_matcher(target, matcher)
    result = matcher.matches?(target)
    return refute(false) unless result

    message = if matcher.respond_to?(:negated_failure_message)
      matcher.method(:negated_failure_message).arity.zero? ? matcher.negated_failure_message : matcher.negated_failure_message(target)
    else
      "expected #{target.inspect} not to match"
    end
    flunk message
  end

  def install_dynamic_stub(target, method_name, implementation, any_instance: false, call_original: false)
    owner = any_instance ? target : target.singleton_class
    mod = Module.new do
      define_method(method_name) do |*args, **kwargs, &block|
        TestSupport.record_dynamic_call(target, self, method_name, args, kwargs, block)
        if implementation
          if kwargs.empty?
            implementation.call(*args, &block)
          else
            implementation.call(*args, **kwargs, &block)
          end
        elsif call_original
          if kwargs.empty?
            super(*args, &block)
          else
            super(*args, **kwargs, &block)
          end
        elsif kwargs.empty?
          super(*args, &block)
        else
          super(*args, **kwargs, &block)
        end
      end
    end
    owner.prepend(mod)
    (@dynamic_stub_modules ||= []) << mod
  end

  def cleanup_dynamic_stubs
    Array(@dynamic_stub_modules).each do |mod|
      mod.instance_methods(false).each { |method| mod.send(:remove_method, method) }
    end
    @dynamic_stub_modules = []
    TestSupport.clear_dynamic_calls
  end

  class StubTarget
    def initialize(test, target, expectation:, any_instance: false)
      @test = test
      @target = target
      @expectation = expectation
      @any_instance = any_instance
    end

    def to(matcher, &implementation)
      matcher.with_implementation(&implementation) if implementation && matcher.respond_to?(:with_implementation)
      matcher.install(@target, expectation: @expectation, any_instance: @any_instance, test: @test)
    end
  end
end

Minitest::Spec.register_spec_type(//, ApplicationTest)
