require 'rails_helper'

RSpec.describe "Chats", type: :request do

  let!(:app_with_chats) { create(:application, chats_count: 2) }
  let!(:app_with_no_chats) { create(:application, chats_count: 0) }
  let!(:chat1) { create(:chat, application_token: app_with_chats.token, number: 1) }
  let!(:chat2) { create(:chat, application_token: app_with_chats.token, number: 2) }
  
  # Test suite for GET /api/v1/applications/:application_token/chats
  describe "GET /api/v1/applications/:application_token/chats" do
    context "when no chats found" do
      before {get "/api/v1/applications/#{app_with_no_chats.token}/chats"}
      
      it "returns no chats found" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success") 
        expect(json["data"].size).to eq(0) 
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
    
    context "when chats are found" do
      before {get "/api/v1/applications/#{app_with_chats.token}/chats"}

      it "returns all found chats" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success") 
        expect(json["data"].size).to eq(2)
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end

  # Test suite for GET /api/v1/applications/:application:token/chats/:number
  describe "GET /api/v1/applications/:application_token/chats/:number" do
    
    context "when the record not found" do
      let(:chat_number) { 0 }
      before {get "/api/v1/applications/#{app_with_no_chats.token}/chats/#{chat_number}"}
      
      it "returns status code 404" do
        expect(response).to have_http_status(404) 
      end
    end
    
    context "when the record is found" do
      let(:chat_number) { chat1.number }
      before {get "/api/v1/applications/#{app_with_chats.token}/chats/#{chat_number}"}
      
      it "returns the record" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success")
        expect(json["data"]["number"]).to eq(chat_number)  
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end

  # Test Suite for POST /api/v1/applications/:application_token/chats
  describe "POST /api/v1/applications/:application_token/chats" do
  
    context "creates a chat" do
      before {post "/api/v1/applications/#{app_with_chats.token}/chats"}
      
      it "returns the chat number" do
        json = JSON.parse(response.body)
        expect(json["chat_number"]).not_to be(nil)
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end

  # Test suite for DELETE /api/v1/applications/:application:token/chats/:number
  describe "DELETE /api/v1/applications/:application_token/chats/:number" do
    let(:chat_number) { chat1.number }

    context "when the record is found" do
      before {delete "/api/v1/applications/#{app_with_chats.token}/chats/#{chat_number}"}

      it "returns status code 204" do
        expect(response).to have_http_status(204) 
      end
    end
  end  
end