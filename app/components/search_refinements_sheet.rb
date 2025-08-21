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
      name: "l",
      value: params.dig(:l) || "a",
      data: {
        sync_value_target: "target",
        sync_id: "l"
      }
    )

    Input(
      type: :hidden,
      name: "c",
      value: params.dig(:c) || "a",
      data: {
        sync_value_target: "target",
        sync_id: "c"
      }
    )

    Input(
      id: "selected-author",
      type: :hidden,
      name: "a",
      value: params.dig(:a) || "a",
      data: {
        sync_value_target: "target",
        sync_id: "a"
      }
    )
  end

  def sheet
    cache [ I18n.locale, browser.device.mobile?, hotwire_native_app?, android_native_app?, ios_native_app? ], expires_in: 1.week do
      Sheet do
        SheetTrigger do
          Button(variant: :outline, size: :xl, icon: true) do
            Bootstrap::Sliders(class: "size-5.5")
          end
        end

        SheetContent(
          side: browser.device.mobile? ? :bottom : side,
          with_close_button: false,
          class: [
            "w-[350px] ltr:w-[375px] max-sm:w-full ltr:max-sm:w-full",
            ("pt-[calc(env(safe-area-inset-top)+24px)] pb-[calc(env(safe-area-inset-bottom)+24px)]" if ios_native_app?)
          ]
        ) do
          SheetHeader do
            SheetTitle { t(".title") }
          end

          SheetMiddle(class: "space-y-2") do
            libraries_select
            categories_select
            authors_select
          end

          SheetFooter do
            Button(variant: :primary, data: { action: "click->ruby-ui--sheet-content#close" }) { t("apply") }
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
          value: params.dig(:l) || "a",
          id: "select-a-library",
          data: {
            sync_value_target: "source",
            sync_id: "l",
            sync_event: "change"
          }
        )

        SelectTrigger(class: "mt-1") do
          SelectValue(placeholder: t(".library_placeholder"), id: "select-a-library") { t(".all_libraries") }
        end

        SelectContent(outlet_id: "select-a-library") do
          SelectGroup do
            SelectItem(value: "a", aria_selected!: "true") { t(".all_libraries") }

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
          value: params.dig(:c) || "a",
          id: "select-a-category",
          data: {
            sync_value_target: "source",
            sync_id: "c",
            sync_event: "change"
          }
        )

        SelectTrigger(class: "mt-1") do
          SelectValue(placeholder: t(".category_placeholder"), id: "select-a-category") { t(".all_categories") }
        end

        SelectContent(outlet_id: "select-a-category") do
          SelectGroup do
            SelectItem(value: "a", aria_selected!: "true") { t(".all_categories") }

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
            tom_select_options_value: [ { id: "a", name: t(".all_authors") } ].to_json,
            tom_select_items_value: [ "a" ].to_json,
            tom_select_search_field_value: [ "name" ].to_json,
            tom_select_max_items_value: 1,
            tom_select_preload_value: true,
            tom_select_no_results_value: t(".no_results"),
            tom_select_default_value_source_value: "#selected-author",
            sync_value_target: "source",
            sync_id: "a",
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
