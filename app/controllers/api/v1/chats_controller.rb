module Api
    module V1
        class ChatsController < ApplicationController
            before_action :set_app
            before_action :set_chat, only: [:show, :update, :destroy]
        
            # GET /api/v1/applications/:application_token/chats
            def index
                @chats = @app.chats
                render json: {message: "success", data: @chats.as_json(except: [:id, :application_id])}, status: :ok
            end
            
            # GET /api/v1/applications/:application_token/chats/:number
            def show
                render json: {message: "success", data: @chat.as_json(except: [:id, :application_id])}, status: :ok
            end
            
            # POST /api/v1/applications/:application_token/chats
            def create
                begin
                    chat_number = @app.increment_chats_count
                    ChatWorker.perform_async(@app.id, chat_number)
                    render json: {message: "Chat is to be created!", chat_number: chat_number}, status: :ok
                rescue => exception
                    render json: {message: exception.message}, status: :bad_request
                end
            end
            
            # DELETE /api/v1/applications/:application_token/chats/:number
            def destroy
                @chat.destroy
                render status: :no_content
            end
        
            private
        
            def set_app
                @app = Application.find_by!(token: params[:application_token])
            end
        
            def set_chat
                @chat = @app.chats.find_by!(number: params[:number])
            end
        end
    end
end
