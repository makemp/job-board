class CreateBillingDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :billing_details, id: :ulid do |t|
      t.string :employer_id, null: false
      t.string :company_name
      t.string :tax_id
      t.string :address
      t.string :city
      t.string :zip
      t.string :country

      t.timestamps
    end
    add_index :billing_details, :employer_id, unique: true
    add_foreign_key :billing_details, :employers, column: :employer_id
  end
end
