class ChatWorker
    include Sidekiq::Worker

    def perform(app_token, chat_number)
        chat = Chat.new(application_token: app_token, number: chat_number)
        begin
            chat.save!
            puts("****** Chat number #{chat_number} in Application #{app_token} created successfully! ******")
        rescue => exception
            puts("Can't create chat: #{exception.message}")
        end
    end
end