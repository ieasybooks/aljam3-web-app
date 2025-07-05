class AddAuthorIdToBooks < ActiveRecord::Migration[8.0]
  def up
    add_reference :books, :author, foreign_key: true

    Book.find_each do |book|
      book.author = Author.find_by(name: book.author_name)
      book.save!
    end

    change_column_null :books, :author_id, false
  end

  def down
    Book.find_each do |book|
      book.author_name = book.author.name
      book.save!
    end

    remove_reference :books, :author, foreign_key: true
  end
end
