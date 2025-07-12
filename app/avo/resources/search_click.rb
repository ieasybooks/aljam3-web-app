class Avo::Resources::SearchClick < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :result, as: :belongs_to, polymorphic_as: :result, types: [ ::Book, ::Page ]
    field :search_query, as: :belongs_to
  end
end
