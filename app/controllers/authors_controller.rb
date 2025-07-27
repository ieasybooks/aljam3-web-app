class AuthorsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        expires_in 1.week, public: true

        render json: Author.where(hidden: false).order(:name).pluck(:id, :name).map { |id, name| { id:, name: } }
      end

      format.turbo_stream do
        pagy, authors = pagy(Author.where(hidden: false).order(:name))

        render turbo_stream: turbo_stream.replace(
          "results_list_#{params[:page]}",
          Components::AuthorsList.new(authors:, pagy:)
        )
      end

      format.html do
        pagy, authors = pagy(Author.where(hidden: false).order(:name))

        render Views::Authors::Index.new(authors:, pagy:)
      end
    end
  end
end
