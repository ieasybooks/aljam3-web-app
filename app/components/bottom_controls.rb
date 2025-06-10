# frozen_string_literal: true

class Components::BottomControls < Components::Base
  def initialize(book:, files:, current_file:)
    @book = book
    @files = files
    @current_file = current_file
  end

  def view_template
    ControlsBar(class: "justify-center") do |bar|
      div(class: "max-sm:w-full flex items-center max-sm:justify-between gap-x-2") do
        div(class: "flex items-center gap-x-2") do
          first_page_button(bar)
          previous_page_button(bar)
        end

        book_files_dropdown

        div(class: "flex items-center gap-x-2") do
          next_page_button(bar)
          last_page_button(bar)
        end
      end
    end
  end

  private

  def first_page_button(bar)
    bar.tooltip(text: t(".first_page"), content_data: { bottom_controls_target: "firstPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#firstPage", bottom_controls_target: "firstPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronDoubleLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def previous_page_button(bar)
    bar.tooltip(text: t(".previous_page"), content_data: { bottom_controls_target: "previousPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#previousPage", bottom_controls_target: "previousPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def book_files_dropdown
    DropdownMenu do
      DropdownMenuTrigger(class: "w-full") do
        Button(variant: :outline) { t(".book_files") }
      end

      DropdownMenuContent do
        @files.each do |file|
          DropdownMenuItem(
            href: book_page_path(@book, file.pages.first),
            class: [
              "truncate w-full flex items-center justify-between",
              ("bg-accent text-accent-foreground" if file.id == @current_file.id)
            ]
          ) do
            div(class: "truncate") { file.name }

            Hero::Check(variant: :solid, class: "size-4 min-w-4 min-h-4") if file.id == @current_file.id
          end
        end
      end
    end
  end

  def next_page_button(bar)
    bar.tooltip(text: t(".next_page"), content_data: { bottom_controls_target: "nextPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#nextPage", bottom_controls_target: "nextPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def last_page_button(bar)
    bar.tooltip(text: t(".last_page"), content_data: { bottom_controls_target: "lastPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#lastPage", bottom_controls_target: "lastPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronDoubleRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end
end
