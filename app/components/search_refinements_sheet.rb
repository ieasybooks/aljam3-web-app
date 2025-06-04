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
      value: "title-and-content",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[search_scope]"
      }
    )

    Input(
      type: :hidden,
      name: "refinements[library]",
      value: "all-libraries",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[library]"
      }
    )

    Input(
      type: :hidden,
      name: "refinements[category]",
      value: "all-categories",
      data: {
        sync_value_target: "target",
        sync_id: "refinements[category]"
      }
    )
  end

  def sheet
    Sheet do
      SheetTrigger do
        Button(variant: :secondary, size: :xl, icon: true) do
          Hero::Cog8Tooth(variant: :outline, class: "size-6")
        end
      end

      SheetContent(class: "sm:w-sm") do
        SheetHeader do
          SheetTitle { t(".title") }
        end

        SheetMiddle(class: "space-y-2") do
          search_scopes_select
          libraries_select
          categories_select
        end

        SheetFooter do
          Button(variant: :outline, data: { action: "click->ruby-ui--sheet-content#close" }) { t("close") }
        end
      end
    end
  end

  def search_scopes_select
    FormField do
      FormFieldLabel { t(".search_scope") }

      Select do
        SelectInput(
          value: "title-and-content",
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
          value: "all-libraries",
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

            @libraries.each do |library|
              SelectItem(value: library.id) { t(".#{library.name}") }
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
          value: "all-categories",
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

            @categories.each do |category|
              SelectItem(value: category) { category }
            end
          end
        end
      end
    end
  end
end
