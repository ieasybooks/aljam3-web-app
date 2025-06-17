# Rails.application.config.after_initialize do
#   if ENV["DEPLOY"].blank? && Rails.env.production? && ENV.fetch("KAMAL_CONTAINER_NAME", "").start_with?("aljam3-web")
#     GenerateSitemapJob.perform_later
#   end
# end
