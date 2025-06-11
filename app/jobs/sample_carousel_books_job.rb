class SampleCarouselBooksJob < ApplicationJob
  queue_as :default

  def perform = Rails.cache.write("carousel_books_ids", Book.order("RANDOM()").limit(10).pluck(:id))
end
