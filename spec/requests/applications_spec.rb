require 'rails_helper'

RSpec.describe "Applications", type: :request do
  
  let!(:apps) { create_list(:application, 3) }
  let(:app_token) { apps.first.token }

  # Test suite for GET /api/v1/applications
  describe "GET /api/v1/applications" do

      context "when no records exist" do
        let(:apps) {}
        before {get '/api/v1/applications'}
        
        it "returns 0 applications" do
          json = JSON.parse(response.body)
          expect(json["data"].size).to eq(0) 
        end
      end
      
      context "when records found" do
        before {get '/api/v1/applications'}
        
        it "returns all apps" do
          json = JSON.parse(response.body)
          expect(json["data"].size).to eq(3) 
          expect(json["message"]).to eq("success") 
        end

        it "returns status code 200" do
          expect(response).to have_http_status(200) 
        end
      end
  end

  # Test suite for GET /api/v1/applications/:token
  describe "GET /api/v1/applications/:token" do
    
    context "when the record doesn't exist" do
      let(:app_token) { "token" }
      before {get "/api/v1/applications/#{app_token}"}

      it "returns not found message" do
        json = JSON.parse(response.body)
        expect(json["message"]).to match(/Couldn't find Application/)
      end
      
      it "return status code 404" do
        expect(response).to have_http_status(404)
      end
    end

    context "when the record exists" do
      before {get "/api/v1/applications/#{app_token}"}

      it "returns the app" do
        json = JSON.parse(response.body)
        expect((json["data"]["token"])).to eq(app_token) 
      end
      
      it "returns status cod 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end
  
  # Test suite for POST /api/v1/applications
  describe "POST /api/v1/applications" do
    
    context "invalid application" do
      # blank name
      before {post '/api/v1/applications'}
      
      it "returns status code 400" do
        expect(response).to have_http_status(400) 
      end
    end
    
    context "valid appliaction" do
      before {post '/api/v1/applications', params: {name: "new_app"}}

      it "returns the created app" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success")
        expect(json["data"]["name"]).to eq("new_app")
      end
      
      it "returns status code 201" do
        expect(response).to have_http_status(201) 
      end
    end
  end

  # Test suite for PUT /api/v1/applications/:token
  describe "PUT /api/v1/applications/:token" do
    
    context "when the record doesn't exist" do
      let(:app_token) { "token" }
      before {put "/api/v1/applications/#{app_token}"}

      it "returns not found message" do
        json = JSON.parse(response.body)
        expect(json["message"]).to match(/Couldn't find Application/)
      end
      
      it "returns status code 404" do
        expect(response).to have_http_status(404) 
      end
    end
    
    context "when the record exists" do
      before {put "/api/v1/applications/#{app_token}", params: {name: "new_name"}}

      it "returns the updated app" do
        json = JSON.parse(response.body)
        expect(json["data"]["name"]).to eq("new_name") 
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end
end