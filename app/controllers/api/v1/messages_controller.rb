module Api
    module V1
        class MessagesController < ApplicationController
            before_action :set_chat
            before_action :set_message, only: [:show, :update, :destroy]

            def index
                @messages = @chat.messages
                render json: {message: "success", data: @messages.as_json(except: [:id, :chat_id])}, status: :ok
            end

            def show
                render json: {message: "success", data: @message.as_json(except: [:id, :chat_id])}, status: :ok
            end
            
            def create
                msg = Message.new(message_params)
                msg.chat_id = @chat.id
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
            
            def update
                @message.assign_attributes(message_params)
                if msg.invalid?
                    render json: {errors: msg.errors.full_messages}, status: :bad_request
                else
                    msg.save!
                    render json: {message: "success", data: @message.as_json(except: [:id, :chat_id])}, status: :ok
                end
            end
            
            def destroy
                @message.destroy
                render status: :no_content
            end
            
            private

            def message_params
                params.permit(:body)
            end

            def set_chat
                @app = Application.find_by!(token: params[:application_token])
                @chat = @app.chats.find_by!(number: params[:chat_number])
            end

            def set_message
                @message = @chat.messages.find_by!(number: params[:number])
            end
        end
    end
end
