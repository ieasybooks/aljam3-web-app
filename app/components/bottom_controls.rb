# frozen_string_literal: true

class Components::BottomControls < Components::Base
  def initialize(book:, files:, current_file:)
    @book = book
    @files = files
    @current_file = current_file
  end

  def view_template
    ControlsBar(
      container_attrs: {
        data: {
          top_controls_target: "bottomControlsBar"
        }
      },
      class: "justify-center"
    ) do |bar|
      div(class: "max-sm:w-full flex items-center max-sm:justify-between gap-x-2") do
        div(class: "flex items-center gap-x-2") do
          previous_file_button(bar)

          div(
            class: "hidden flex items-center gap-x-2",
            data: {
              bottom_controls_target: "previousPageContainer"
            }
          ) do
            first_page_button(bar)
            previous_page_button(bar)
          end
        end

        book_files_dropdown

        div(class: "flex items-center gap-x-2") do
          div(
            class: "hidden flex items-center gap-x-2",
            data: {
              bottom_controls_target: "nextPageContainer"
            }
          ) do
            next_page_button(bar)
            last_page_button(bar)
          end

          next_file_button(bar)
        end
      end
    end
  end

  private

  def previous_file_button(bar)
    div(
      class: "hidden flex items-center gap-x-2 max-sm:flex-row-reverse",
      data: {
        bottom_controls_target: "previousFileContainer"
      }
    ) do
      bar.dummy_button

      bar.tooltip(text: t(".previous_file"), content_data: { bottom_controls_target: "previousFileButtonTooltip" }) do
        Link(
          href: book_file_path(book_id: @book.id, file_id: previous_file&.id || 0),
          variant: :outline,
          icon: true,
          class: ("pointer-events-none opacity-50" unless previous_file)
        ) do
          Tabler::FileArrowRight(variant: :outline, class: "size-5 ltr:transform ltr:-scale-x-100")
        end
      end
    end
  end

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

      DropdownMenuContent(class: "max-h-54 overflow-y-auto") do
        @files.each do |file|
          DropdownMenuItem(
            href: book_file_path(@book.id, file.id),
            class: [
              "truncate w-full flex items-center justify-between",
              ("bg-accent text-accent-foreground" if file.id == @current_file.id)
            ]
          ) do
            div(class: "truncate") { file.name }

            Lucide::Check(variant: :solid, class: "size-4 min-w-4 min-h-4") if file.id == @current_file.id
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

  def next_file_button(bar)
    div(
      class: "hidden flex items-center gap-x-2 max-sm:flex-row-reverse",
      data: {
        bottom_controls_target: "nextFileContainer"
      }
    ) do
      bar.tooltip(text: t(".next_file"), content_data: { bottom_controls_target: "nextFileButtonTooltip" }) do
        Link(
          href: book_file_path(book_id: @book.id, file_id: next_file&.id || 0),
          variant: :outline,
          icon: true,
          class: ("pointer-events-none opacity-50" unless next_file)
        ) do
          Tabler::FileArrowLeft(variant: :outline, class: "size-5 ltr:transform ltr:-scale-x-100")
        end
      end

      bar.dummy_button
    end
  end

  def previous_file
    return @previous_file if defined?(@previous_file)

    previous_file_index = @files.index(@current_file) - 1

    @previous_file = if previous_file_index == -1
      nil
    else
      @files[previous_file_index]
    end
  end

  def next_file
    return @next_file if defined?(@next_file)

    next_file_index = @files.index(@current_file) + 1

    @next_file = if next_file_index == @files.size
      nil
    else
      @files[next_file_index]
    end
  end
end
