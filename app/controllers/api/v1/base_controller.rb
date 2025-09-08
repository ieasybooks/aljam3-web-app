class Api::V1::BaseController < ActionController::API
  include Pagy::Backend

  before_action :set_default_response_format
  helper_method :process_meilisearch_highlights

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def set_default_response_format = request.format = :json
  def not_found = render json: { error: "Resource not found" }, status: :not_found

  # :nocov:
  def process_meilisearch_highlights(content) = merge_consecutive_marks(remove_definite_articles_marks(content))
  def remove_definite_articles_marks(content) = content&.gsub(/<mark>(ال|أل|إل|آل)<\/mark>(?!<mark>)/, '\1')
  def merge_consecutive_marks(content) = content&.gsub(/<\/mark>(\s*)<mark>/) { Regexp.last_match(1).empty? ? "" : "&nbsp;" }
  # :nocov:
end
