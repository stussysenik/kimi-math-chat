class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :title
      t.string :model_id, default: "moonshotai/kimi-k2-instruct"
      t.text :system_prompt
      t.string :session_id

      t.timestamps
    end
  end
end
