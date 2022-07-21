class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      t.integer :number, null: false
      t.integer :messages_count, null: false, default: 0
      t.references :application, null: false, index: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
    add_index :chats, [:application_id, :number], unique: true
  end
end