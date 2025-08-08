class AuthorsController < ApplicationController
  before_action :set_author, only: :show
  before_action :check_hidden, only: :show

  def index
    respond_to do |format|
      format.json do
        expires_in 1.week, public: true

        render json: Author.where(hidden: false).order(:name).pluck(:id, :name).map { |id, name| { id:, name: } }
      end

      format.turbo_stream do
        pagy, authors = search_or_list_authors

        render turbo_stream: turbo_stream.replace(
          "results_list_#{pagy.page}",
          Components::AuthorsList.new(authors:, pagy:)
        )
      end

      format.html do
        pagy, authors = search_or_list_authors

        render Views::Authors::Index.new(authors:, pagy:)
      end
    end
  end

  def show
    if params[:qid].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:i].presence&.to_i || -1, search_query_id: params[:qid], result: @author)
    end

    pagy, books = search_or_list_books

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "results_list_#{params[:page]}",
          Components::AuthorBooksList.new(author: @author, books:, pagy:)
        )
      end

      format.html do
        render Views::Authors::Show.new(author: @author, books:, pagy:)
      end
    end
  end

  private

  def set_author = @author = Author.find(params[:id])

  def check_hidden
    redirect_to root_path if @author.hidden
  end

  def search_or_list_authors
    if params[:q].present?
      pagy_meilisearch(Author.pagy_search(
        params[:q],
        filter: "hidden = false",
        highlight_pre_tag: "<mark>",
        highlight_post_tag: "</mark>"
      ))
    else
      pagy(Author.where(hidden: false).order(:name))
    end
  end

  def search_or_list_books
    if params[:q].present?
      pagy_meilisearch(Book.pagy_search(
        params[:q],
        filter: %(hidden = false AND author = "#{@author.id}"),
        highlight_pre_tag: "<mark>",
        highlight_post_tag: "</mark>"
      ))
    else
      pagy(@author.books.where(hidden: false).order(:title))
    end
  end
end
