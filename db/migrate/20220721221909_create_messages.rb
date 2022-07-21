class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.integer :number, null: false
      t.text :body, null: false
      t.references :chat, null: false, index:false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
    add_index :messages, [:chat_id, :number], unique: true
  end
end
