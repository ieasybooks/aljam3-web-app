# For testing rake tasks
require "rake"

# Task names should be used in the top-level describe, with an optional
# "rake "-prefix for better documentation. Both of these will work:
#
# 1) describe "foo:bar" do ... end
#
# 2) describe "rake foo:bar" do ... end
#
# Favor including "rake "-prefix as in the 2nd example above as it produces
# doc output that makes it clear a rake task is under test and how it is
# invoked.
module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    let(:task_name) do
      task_group = self.class.ancestors.find do |ancestor|
        ancestor.respond_to?(:desc) && ancestor.desc.to_s.start_with?("rake ")
      end
      task_group.desc.to_s.sub(/\Arake /, "")
    end
    let(:tasks) { Rake::Task }
    subject(:task) { tasks[task_name] }

    after do
      task.all_prerequisite_tasks.each { |prerequisite| tasks[prerequisite].reenable }
      task.reenable
    end
  end
end

Rails.application.load_tasks
