class CreateEmailRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :email_records do |t|
      t.string :email
      t.references :shareable, polymorphic: true, index: true
      t.jsonb :additional_info, default: {}

      t.timestamps
    end

    add_index :email_records, [:email, :shareable_type, :shareable_id], unique: true, name: 'index_email_records_unique'
  end
end