class AddAppTokenToChats < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :chats, :applications, column: :application_token, primary_key: :token
  end
end
