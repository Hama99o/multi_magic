class AddDurationToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :blog_app_articles, :duration, :string
  end
end
