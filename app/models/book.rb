# == Schema Information
#
# Table name: books
#
#  id         :bigint           not null, primary key
#  author     :string           not null
#  category   :string           not null
#  pages      :integer          not null
#  title      :string           not null
#  volumes    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  library_id :bigint           not null
#
# Indexes
#
#  index_books_on_library_id  (library_id)
#
# Foreign Keys
#
#  fk_rails_...  (library_id => libraries.id)
#
class Book < ApplicationRecord
  include Meilisearch::Rails

  extend Pagy::Meilisearch
  ActiveRecord_Relation.include Pagy::Meilisearch

  belongs_to :library
  has_many :files, class_name: "BookFile", dependent: :destroy
  has_many :pdf_files, -> { where(file_type: :pdf) }, class_name: "BookFile"
  has_many :txt_files, -> { where(file_type: :txt) }, class_name: "BookFile"
  has_many :docx_files, -> { where(file_type: :docx) }, class_name: "BookFile"

  validates :title, :author, :category, :volumes, :pages, presence: true

  meilisearch enqueue: true do
    attribute :title, :category, :author

    attribute :library do
      # :nocov:
      library_id
      # :nocov:
    end

    attributes_to_highlight %i[title]
    searchable_attributes %i[title]
    filterable_attributes %i[category author library]
  end
end
