class AddAuthorAndCategoryIdsToBooks < ActiveRecord::Migration[8.0]
  def up
    add_reference :books, :author, foreign_key: true
    add_reference :books, :category, foreign_key: true

    Book.find_each do |book|
      book.author = Author.find_by(name: book.author_name)
      book.category = Category.find_by(name: book.category_name)
      book.save!
    end

    change_column_null :books, :author_id, false
    change_column_null :books, :category_id, false
  end

  def down
    Book.find_each do |book|
      book.author_name = book.author.name
      book.category_name = book.category.name
      book.save!
    end

    remove_reference :books, :author, foreign_key: true
    remove_reference :books, :category, foreign_key: true
  end
end
