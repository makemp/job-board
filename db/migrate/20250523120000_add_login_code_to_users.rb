class AddLoginCodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :login_code, :string
    add_column :users, :login_code_sent_at, :datetime
  end
end
