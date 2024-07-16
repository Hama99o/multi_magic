class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :file # This will store the image file URL or path
      t.references :imageable, polymorphic: true, null: false # Polymorphic association
      t.timestamps
    end
  end
end
