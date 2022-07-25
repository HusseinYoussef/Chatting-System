class AddIndexOnAppTokenAndChatNumberToChats < ActiveRecord::Migration[5.0]
  def change
    add_index :chats, [:application_token, :number], unique: true
  end
end
