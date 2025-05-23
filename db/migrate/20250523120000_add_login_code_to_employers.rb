class AddLoginCodeToEmployers < ActiveRecord::Migration[6.1]
  def change
    add_column :employers, :login_code, :string
    add_column :employers, :login_code_sent_at, :datetime
  end
end

