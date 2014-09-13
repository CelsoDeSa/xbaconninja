class AddCategoryToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :category, :string
    remove_column :blogs, :category
  end
end
