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
                @app = Application.new(app_params)
                if @app.invalid?
                    render json: {errors: @app.errors.full_messages}, status: :bad_request
                else
                    @app.save!
                    render json: {message: "success", data: @app.as_json(except: :id)}, status: :created
                end
            end
            
            # PUT api/v1/applications/:token
            def update
                @app.assign_attributes(app_params)
                if @app.invalid?
                    render json: {errors: @app.errors.full_messages}, status: :bad_request
                else
                    @app.save!
                    render json: {message: "success", data: @app.as_json(except: :id)}, status: :ok
                end
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
