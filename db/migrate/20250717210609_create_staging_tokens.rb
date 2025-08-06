class CreateStagingTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :staging_tokens do |t|
      t.string :value

      t.timestamps
    end
    add_index :staging_tokens, :value, unique: true
  end
end
