require "rake"

class GenerateSitemapJob < ApplicationJob
  queue_as :sitemap
  limits_concurrency to: 1, key: ->() { ENV["KAMAL_VERSION"] }, duration: 100.years

  def perform
    load_rake_tasks_once

    Rake::Task["sitemap:refresh"].invoke
  end

  private

  def load_rake_tasks_once
    return if Rake::Task.task_defined?("sitemap:refresh")

    Rails.application.load_tasks
  end
end
