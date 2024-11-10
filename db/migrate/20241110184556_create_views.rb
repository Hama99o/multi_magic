class CreateViews < ActiveRecord::Migration[7.0]
  def change
    create_table :views do |t|
      t.references :viewable, polymorphic: true, null: false        # Polymorphic association
      t.references :user, foreign_key: true                         # For logged-in users; null for guests
      t.string :ip_address                                          # For guest users
      t.string :user_agent                                          # For guest users
      t.timestamps
    end

    # Add unique index to prevent duplicate views for logged-in users on the same viewable object
    add_index :views, [:viewable_type, :viewable_id, :user_id], unique: true, where: 'user_id IS NOT NULL', name: 'index_views_on_viewable_and_user'

    # Add unique index to prevent duplicate views for guests (based on IP and user agent)
    add_index :views, [:viewable_type, :viewable_id, :ip_address, :user_agent], unique: true, where: 'user_id IS NULL', name: 'index_views_on_viewable_and_ip_agent'
  end
end
