class Components::FavoritesToggle < Components::Base
  def initialize(user: nil, active: false)
    @user = user
    @active = active
  end

  def view_template
    return unless @user

    Link(
      href: favorites_filter_url,
      variant: @active ? :primary : :outline,
      size: :lg,
      data: { turbo_frame: "_top" },
      class: "h-12 self-end"
    ) do
      Hero::Heart(class: "size-4 #{direction == :rtl ? "ml-2" : "mr-2"}", variant: @active ? :solid : :outline)
      span { t("components.favorites_toggle.button_text") }
    end
  end

  private

  def favorites_filter_url
    # Manually build the parameters hash to avoid ActionController::Parameters issues
    current_params = {}

    # Preserve important parameters
    current_params["q"] = params[:q] if params[:q].present?

    if @active
      # Remove favorites filter
      current_params.delete("favorites")
      books_path(current_params)
    else
      # Add favorites filter
      current_params["favorites"] = "true"
      books_path(current_params)
    end
  end
end
