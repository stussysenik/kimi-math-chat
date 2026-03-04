class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.integer :role
      t.text :content
      t.boolean :streaming, default: false
      t.boolean :contains_math, default: false
      t.json :metadata

      t.timestamps
    end
  end
end
