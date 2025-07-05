class CreateAuthorRecords < ActiveRecord::Migration[8.0]
  def up
    Book.pluck(:author_name).uniq.sort.each do |author_name|
      Author.create(name: author_name)
    end
  end
end
