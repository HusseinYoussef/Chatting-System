module Api
    module V1
        class ApplicationsController < ApplicationController
            before_action :set_app, only: [:show, :update]

            # GET api/v1/applications
            def index
                @apps = Application.all
                render json: {message: "success", data: @apps.as_json(except: :id)}, status: :ok
            end
            
            # GET api/v1/applications/:token
            def show
                render json: {message: "success", data: @app.as_json(except: :id)}, status: :ok
            end
            
            # POST api/v1/applications
            def create
                @app = Application.create!(app_params)
                render json: {message: "success", data: @app.as_json(except: :id)}, status: :created
            end
            
            # PUT api/v1/applications/:token
            def update
                @app.update!(app_params)
                render json: {message: "success", data: @app.as_json(except: :id)}, status: :ok
            end
            
            private

            def app_params
                params.permit(:name)
            end
    
            def set_app
                @app = Application.find_by!(token: params[:token])
            end
        end
    end
end
