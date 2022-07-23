class MessageWorker
    include Sidekiq::Worker

    def perform(chat_id, msg_number, msg_body)
        message = Message.new(chat_id: chat_id, number: msg_number, body: msg_body)
        if message.save
            puts("****** Message created successfully! ******")
        else
            raise "Can't create message"
        end
    end
end