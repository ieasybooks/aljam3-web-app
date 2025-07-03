# Use it like this:
# ReindexMeilisearchJob.perform_later("Page", 1, 1000000)
class ReindexMeilisearchJob < ApplicationJob
  queue_as :default

  def perform(model, start_id, end_id, step = 10000)
    # TODO: Remove this after reindexing is complete, and use ActiveJob::Continuable when it's released.
    start_id = 1130000

    model_class = model.constantize

    start_id.step(end_id, step) do |range_start_id|
      range_end_id = [ range_start_id + step - 1, end_id ].min
      model_class.where(id: range_start_id..range_end_id).reindex!

      sleep 300
    end
  end
end
