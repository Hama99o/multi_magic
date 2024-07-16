class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true
      t.string :city
      t.string :country
      t.integer :postal_code
      t.string :state
      t.boolean :is_default

      t.timestamps
    end
  end
end
