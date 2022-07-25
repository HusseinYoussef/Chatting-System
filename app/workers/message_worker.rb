class MessageWorker
    include Sidekiq::Worker

    def perform(chat_id, msg_number, msg_body)
        message = Message.new(chat_id: chat_id, number: msg_number, body: msg_body)
        begin
            message.save!
            puts("****** Message number #{msg_number} in chat_id #{chat_id} created successfully! ******")
        rescue => exception
            puts("Can't create message: #{exception.message}")
        end
    end
end