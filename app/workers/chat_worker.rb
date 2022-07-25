class ChatWorker
    include Sidekiq::Worker

    def perform(app_id, app_token, chat_number)
        chat = Chat.new(application_id: app_id, application_token: app_token, number: chat_number)
        if chat.save
            puts("****** Chat created successfully! ******")
        else
            raise "Can't create chat"
        end
    end
end