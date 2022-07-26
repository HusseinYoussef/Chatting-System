module Api
    module V1
        class MessagesController < ApplicationController
            before_action :set_chat
            before_action :set_message, only: [:show, :update, :destroy]

            # GET /api/v1/applications/:application_token/chats/:chat_number/messages
            def index
                @messages = @chat.messages
                render json: {message: "success", data: @messages.as_json(except: [:id, :chat_id])}, status: :ok
            end
            
            # GET /api/v1/applications/:application_token/chats/:chat_number/messages/:number
            def show
                render json: {message: "success", data: @message.as_json(except: [:id, :chat_id])}, status: :ok
            end
            
            # POST /api/v1/applications/:application_token/chats/:chat_number/messages
            def create
                msg = Message.new(message_params)
                msg.chat_id = @chat.id
                msg.number = 0 # tmp value
                if msg.invalid?
                    render json: {errors: msg.errors.full_messages}, status: :bad_request
                else
                    begin
                        message_number = @chat.increment_chat_messages_counter
                        MessageWorker.perform_async(@chat.id, message_number, message_params[:body])
                        render json: {message: "Message is to be created!", message_number: message_number}, status: :ok
                    rescue => exception
                        render json: {message: "Couldn't create message"}, status: :bad_request
                    end
                end
            end
            
            # PUT /api/v1/applications/:application_token/chats/:chat_number/messages/:number
            def update
                @message.assign_attributes(message_params)
                if @message.invalid?
                    render json: {errors: @message.errors.full_messages}, status: :bad_request
                else
                    @message.save!
                    render json: {message: "success", data: @message.as_json(except: [:id, :chat_id])}, status: :ok
                end
            end
            
            # DELETE /api/v1/applications/:application_token/chats/:chat_number/messages/:number
            def destroy
                @message.destroy
                render status: :no_content
            end
            
            # POST /api/v1/applications/:application_token/chats/:chat_number/messages/search
            def search
                if params[:query].nil? or params[:query].empty?
                    render json: {message: "Query can't be empty"}, status: :bad_request
                else
                    begin
                        results = Message.search(@chat.id, params[:query]).map { |result| result["_source"] }
                        render json: {message: "success", number_of_messages: results.size, data: results}, status: :ok
                    rescue => exception
                        render json: {message: exception.message}, status: :bad_request
                    end
                end
            end

            private

            def message_params
                params.permit(:body)
            end

            def set_chat
                @chat = Chat.find_by!(application_token: params[:application_token], number: params[:chat_number])
            end

            def set_message
                @message = @chat.messages.find_by!(number: params[:number])
            end
        end
    end
end
