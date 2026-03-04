class CreateVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :verifications do |t|
      t.references :message, null: false, foreign_key: true
      t.string :verifier
      t.integer :status, default: 0
      t.text :input_expression
      t.text :result
      t.text :error_message
      t.float :execution_time_ms

      t.timestamps
    end
  end
end
