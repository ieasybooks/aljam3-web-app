class Avo::Resources::BookFile < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :pdf_url, as: :textarea
    field :txt_url, as: :textarea
    field :docx_url, as: :textarea
    field :pages_count, as: :number, readonly: true
    field :book, as: :belongs_to
    field :pages, as: :has_many
  end
end
