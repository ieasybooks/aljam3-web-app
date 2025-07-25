class Avo::Resources::Author < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :hidden, as: :boolean
    field :books_count, as: :number
    field :books, as: :has_many
  end
end
