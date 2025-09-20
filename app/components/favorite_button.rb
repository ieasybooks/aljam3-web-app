# frozen_string_literal: true

class Components::FavoriteButton < Components::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    div(id: "favorite_#{@book.id}") do
      if user_signed_in?
        if favorited?
          Link(
            href: book_favorite_path(@book.id, favorite_id),
            variant: :ghost,
            size: :sm,
            icon: true,
            data: { turbo_method: :delete }
          ) do
            Hero::Heart(variant: :solid, class: "size-4 text-red-500")
          end
        else
          Link(
            href: book_favorites_path(@book.id),
            variant: :ghost,
            size: :sm,
            icon: true,
            data: { turbo_method: :post }
          ) do
            Hero::Heart(variant: :outline, class: "size-4")
          end
        end
      else
        # Clickable heart that redirects to sign-in for unauthenticated users
        Link(
          href: new_user_session_path,
          variant: :ghost,
          size: :sm,
          icon: true,
          title: t("components.favorite_button.sign_in_to_favorite")
        ) do
          Hero::Heart(variant: :outline, class: "size-4 text-muted-foreground")
        end
      end
    end
  end

  private

  def favorited?
    return false unless user_signed_in?

    current_user.favorites.exists?(book: @book)
  end

  def favorite_id
    return nil unless favorited?

    current_user.favorites.find_by(book: @book).id
  end
end
