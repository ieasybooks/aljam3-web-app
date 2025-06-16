class GenerateSitemapJob < ApplicationJob
  queue_as :sitemap
  limits_concurrency to: 1, key: ->() { ENV["KAMAL_VERSION"] }, duration: 100.years

  def perform = SitemapGenerator::Interpreter.run(verbose: false)
end
