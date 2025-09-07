class Api::V1::BaseController < ActionController::API
  include Pagy::Backend

  before_action :set_default_response_format

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def set_default_response_format = request.format = :json
  def not_found = render json: { error: "Resource not found" }, status: :not_found
end
