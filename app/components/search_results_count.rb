class Components::SearchResultsCount < Components::Base
  def initialize(count:, **attrs)
    @count = count > 1000 ? 1000 : count

    super(**attrs)
  end

  def view_template
    Text(**attrs) do
      t(".results_count", count: number_with_delimiter(@count))
    end
  end

  private

  def default_attrs = {}
end
