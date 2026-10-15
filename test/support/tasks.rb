# frozen_string_literal: true

require "rake"

module TaskSupport
  def task(name)
    Rake::Task[name]
  end

  def teardown
    super

    Rake::Task.tasks.each do |rake_task|
      rake_task.all_prerequisite_tasks.each(&:reenable)
      rake_task.reenable
    end
  end
end

Rails.application.load_tasks
