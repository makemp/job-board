class AddSlugToBlogPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :blog_posts, :slug, :string
    add_index :blog_posts, :slug, unique: true
  rescue => e
    Rails.logger.info("Error adding slug column or index to blog_posts: #{e.message}")
  end
end
