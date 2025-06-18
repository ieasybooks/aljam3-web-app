Rails.application.config.after_initialize do
  GenerateSitemapJob.perform_later if ENV["ENQUEUE_GENERATE_SITEMAP_JOB"].present?
end
