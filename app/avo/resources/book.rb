class Avo::Resources::Book < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :volumes, as: :number
    field :pages_count, as: :number
    field :files_count, as: :number, readonly: true
    field :library, as: :belongs_to
    field :files, as: :has_many
    field :pages, as: :has_many, through: :files
    field :author, as: :belongs_to
    field :category, as: :belongs_to
  end
end
