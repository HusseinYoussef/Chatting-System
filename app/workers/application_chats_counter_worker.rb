class ApplicationChatsCounterWorker
    include Sidekiq::Worker

    def perform
        Application.find_each do |application|
            application.chats_count = Chat.where(application_token: application.token).length()
            application.save!
        end
        puts('****** All Applications Chats_Counter have been updated successfully! ******')
    end
end