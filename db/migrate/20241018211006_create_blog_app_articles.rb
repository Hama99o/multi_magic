class CreateBlogAppArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :blog_app_articles do |t|
      t.string :title
      t.text :subtitle
      t.datetime :published_at
      t.references :user, null: false, foreign_key: true
      t.datetime :deleted_at
      t.integer :status, default: 0, null: false
      t.jsonb :description

      t.timestamps
    end
  end
end
