class AuthorsController < ApplicationController
  def index
    expires_in 1.week, public: true

    render json: Author.where(hidden: false).order(:name).pluck(:id, :name).map { |id, name| { id:, name: } }
  end
end
