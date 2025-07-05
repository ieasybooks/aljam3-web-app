class CreateCategoryRecords < ActiveRecord::Migration[8.0]
  def up
    Book.pluck(:category_name).uniq.sort.each do |category_name|
      Category.create(name: category_name)
    end
  end
end
