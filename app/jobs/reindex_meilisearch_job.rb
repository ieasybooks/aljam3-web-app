class ReindexMeilisearchJob < ApplicationJob
  queue_as :default

  def perform(model, start_id, end_id) = model.constantize.where(id: start_id..end_id).reindex!
end
