# frozen_string_literal: true

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  include Components

  PageInfo = Data.define(:title, :no_navbar)

  def around_template
    if layout
      render layout.new(page_info) do
        super
      end
    else
      super
    end
  end

  def layout = Components::Layout
  def page_title = t("aljam3")
  def no_navbar = false

  def page_info
    PageInfo.new(
      title: page_title,
      no_navbar: no_navbar
    )
  end
end
