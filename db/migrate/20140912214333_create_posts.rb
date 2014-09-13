class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :media
      t.string :title
      t.string :url
      t.text :content
      t.belongs_to :blog, index: true

      t.timestamps
    end
  end
end
