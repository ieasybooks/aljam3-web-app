# frozen_string_literal: true

class Components::SearchRefinementsSheet < Components::Base
  def initialize(libraries:, categories:)
    @libraries = libraries
    @categories = categories
  end

  def view_template
    hidden_inputs
    sheet
  end

  private

  def hidden_inputs
    Input(
      type: :hidden,
      name: "refinements[search_scope]",
      value: params.dig(:refinements, :search_scope) || "title-and-content",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[search_scope]"
      }
    )

    Input(
      type: :hidden,
      name: "refinements[library]",
      value: params.dig(:refinements, :library) || "all-libraries",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[library]"
      }
    )

    Input(
      type: :hidden,
      name: "refinements[category]",
      value: params.dig(:refinements, :category) || "all-categories",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[category]"
      }
    )

    Input(
      id: "selected-author",
      type: :hidden,
      name: "refinements[author]",
      value: params.dig(:refinements, :author) || "all-authors",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[author]"
      }
    )
  end

  def sheet
    cache expires_in: 1.week do
      Sheet do
        SheetTrigger do
          Button(variant: :outline, size: :xl, icon: true) do
            Bootstrap::Sliders(class: "size-5.5")
          end
        end

        SheetContent(side: browser.device.mobile? ? :bottom : side, with_close_button: false, class: "w-[350px] max-sm:w-full") do
          SheetHeader do
            SheetTitle { t(".title") }
          end

          SheetMiddle(class: "space-y-2") do
            search_scopes_select
            libraries_select
            categories_select
            authors_select
          end

          SheetFooter do
            Button(variant: :outline, data: { action: "click->ruby-ui--sheet-content#close" }) { t("apply") }
          end
        end
      end
    end
  end

  def search_scopes_select
    FormField do
      FormFieldLabel { t(".search_scope") }

      Select do
        SelectInput(
          value: params.dig(:refinements, :search_scope) || "title-and-content",
          id: "select-a-search-scope",
          data: {
            sync_value_target: "source",
            sync_id: "refinements[search_scope]",
            sync_event: "change"
          }
        )

        SelectTrigger(class: "mt-1") do
          SelectValue(placeholder: t(".search_scope_placeholder"), id: "select-a-search-scope") do
            t(".search_scope_title_and_content")
          end
        end

        SelectContent(outlet_id: "select-a-search-scope") do
          SelectGroup do
            SelectItem(value: "title-and-content", aria_selected!: "true") { t(".search_scope_title_and_content") }
            SelectItem(value: "title") { t(".search_scope_title") }
            SelectItem(value: "content") { t(".search_scope_content") }
          end
        end
      end
    end
  end

  def libraries_select
    FormField do
      FormFieldLabel { t(".library") }

      Select do
        SelectInput(
          value: params.dig(:refinements, :library) || "all-libraries",
          id: "select-a-library",
          data: {
            sync_value_target: "source",
            sync_id: "refinements[library]",
            sync_event: "change"
          }
        )

        SelectTrigger(class: "mt-1") do
          SelectValue(placeholder: t(".library_placeholder"), id: "select-a-library") { t(".all_libraries") }
        end

        SelectContent(outlet_id: "select-a-library") do
          SelectGroup do
            SelectItem(value: "all-libraries", aria_selected!: "true") { t(".all_libraries") }

            @libraries.call.each do |id, name|
              SelectItem(value: id) { t(".#{name}") }
            end
          end
        end
      end
    end
  end

  def categories_select
    FormField do
      FormFieldLabel { t(".category") }

      Select do
        SelectInput(
          value: params.dig(:refinements, :category) || "all-categories",
          id: "select-a-category",
          data: {
            sync_value_target: "source",
            sync_id: "refinements[category]",
            sync_event: "change"
          }
        )

        SelectTrigger(class: "mt-1") do
          SelectValue(placeholder: t(".category_placeholder"), id: "select-a-category") { t(".all_categories") }
        end

        SelectContent(outlet_id: "select-a-category") do
          SelectGroup do
            SelectItem(value: "all-categories", aria_selected!: "true") { t(".all_categories") }

            @categories.call.each do |id, name, count|
              SelectItem(value: id) { "#{name} (#{number_with_delimiter(count)} #{t(".books")})" }
            end
          end
        end
      end
    end
  end

  def authors_select
    FormField do
      FormFieldLabel { t(".author") }

      div(class: "relative") do
        Input(
          class: "flex items-center mt-1 p-0 border-none",
          autocomplete: :off,
          data: {
            controller: "tom-select",
            tom_select_url_value: authors_path,
            tom_select_plugins_value: [ "dropdown_input", "no_backspace_delete" ].to_json,
            tom_select_value_field_value: "id",
            tom_select_label_field_value: "name",
            tom_select_options_value: [ { id: "all-authors", name: t(".all_authors") } ].to_json,
            tom_select_items_value: [ "all-authors" ].to_json,
            tom_select_search_field_value: [ "name" ].to_json,
            tom_select_max_items_value: 1,
            tom_select_preload_value: true,
            tom_select_no_results_value: t(".no_results"),
            tom_select_default_value_source_value: "#selected-author",
            sync_value_target: "source",
            sync_id: "refinements[author]",
            sync_event: "change"
          }
        )

        svg(
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          class: "absolute top-1/2 -translate-y-1/2 end-3 ms-2 h-4 w-4 shrink-0 opacity-50",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round"
        ) do |s|
          s.path(d: "m7 15 5 5 5-5")
          s.path(d: "m7 9 5-5 5 5")
        end
      end
    end
  end
end
