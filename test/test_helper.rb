# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "padded_cell"
require "mocha/minitest"
require "webmock/minitest"

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

require_relative "../config/environment"
require "rails/test_help"

abort("The Rails environment is running in production mode!") if Rails.env.production?

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module MeilisearchTestIsolation
  def ms_index_uid(*)
    "#{super}_#{Process.pid}"
  end
end

[ Page, Book, Author, Category ].each do |model|
  model.singleton_class.prepend(MeilisearchTestIsolation)
end

class ApplicationTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods
  include Devise::Test::IntegrationHelpers
  include McpRequests

  setup do
    WebMock.reset!
  end
end

class ModelTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    WebMock.reset!
  end

  private

  def assert_model_matcher(matcher, model)
    subject = model.new
    matched = matcher.matches?(subject)
    assert matched, matcher.description
  end
end

class ScriptTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    WebMock.reset!
  end
end
