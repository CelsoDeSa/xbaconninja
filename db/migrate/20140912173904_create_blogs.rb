class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :name
      t.string :url
      t.string :feed
      t.string :category

      t.timestamps
    end
  end
end
