class ErrorsController < ApplicationController
  def not_found = render Views::Errors::NotFound.new, status: :not_found

  def unprocessable_content = render Views::Errors::UnprocessableContent.new, status: :unprocessable_content

  def internal_server_error = render Views::Errors::InternalServerError.new, status: :internal_server_error

  def unsupported_browser = render Views::Errors::UnsupportedBrowser.new, status: :not_acceptable

  def bad_request = render Views::Errors::BadRequest.new, status: :bad_request
end
