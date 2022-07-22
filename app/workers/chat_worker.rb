class ChatWorker
    include Sidekiq::Worker

    def perform(app_id, chat_number)
        chat = Chat.new(application_id: app_id, number: chat_number)
        if chat.save
            puts("****** Chat created successfully! ******")
        else
            raise "Can't create chat"
        end
    end
end