class ChatMessagesCounterWorker
    include Sidekiq::Worker

    def perform
        Chat.find_each do |chat|
            chat.messages_count = Message.where(chat_id: chat.id).length()
            chat.save!
        end
        puts('****** All Chats Messages_Counter have been updated successfully! ******')
    end
end