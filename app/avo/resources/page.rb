class Avo::Resources::Page < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  self.pagination = {
    type: :countless
  }

  def fields
    field :id, as: :id
    field :content, as: :textarea
    field :number, as: :number
    field :file, as: :belongs_to
  end
end
