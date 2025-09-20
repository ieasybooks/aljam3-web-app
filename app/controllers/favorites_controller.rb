class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, except: [ :index ]

  def index
    pagy, favorites = pagy(current_user.favorites.includes(:book))
    render Views::Favorites::Index.new(favorites: favorites, pagy: pagy)
  end

  def create
    @favorite = current_user.favorites.find_or_initialize_by(book: @book)

    if @favorite.persisted?
      # Already favorited, just return success
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "favorite_#{@book.id}",
            Components::FavoriteButton.new(book: @book)
          )
        end
        format.html { redirect_back(fallback_location: books_path) }
      end
    elsif @favorite.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "favorite_#{@book.id}",
            Components::FavoriteButton.new(book: @book)
          )
        end
        format.html { redirect_back(fallback_location: books_path) }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_content }
        format.html { redirect_back(fallback_location: books_path, alert: t("favorites.create.error")) }
      end
    end
  end

  def destroy
    @favorite = current_user.favorites.find_by(book: @book)

    if @favorite&.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "favorite_#{@book.id}",
            Components::FavoriteButton.new(book: @book)
          )
        end
        format.html { redirect_back(fallback_location: books_path) }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_content }
        format.html { redirect_back(fallback_location: books_path, alert: t("favorites.destroy.error")) }
      end
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end
end
