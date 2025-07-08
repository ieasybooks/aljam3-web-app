class AuthorsController < ApplicationController
  def index = render json: Author.order(:name).pluck(:id, :name).map { |id, name| { id:, name: } }
end
