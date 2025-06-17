# Use it like this:
# Page.in_batches(of: 1000).each do |batch|
#   ReindexMeilisearchJob.perform_later("Page", batch.first.id, batch.last.id)
# end
class ReindexMeilisearchJob < ApplicationJob
  queue_as :default

  def perform(model, start_id, end_id) = model.constantize.where(id: start_id..end_id).reindex!
end
