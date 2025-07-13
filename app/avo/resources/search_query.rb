class Avo::Resources::SearchQuery < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :query, as: :text
    field :refinements, as: :code, language: "javascript"
    field :user, as: :belongs_to
    field :search_clicks, as: :has_many
  end
end
