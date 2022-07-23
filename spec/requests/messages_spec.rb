require 'rails_helper'

RSpec.describe "Messages", type: :request do
  
  let!(:app_with_chats) { create(:application, chats_count: 2) }
  let!(:chat) { create(:chat, application_id: app_with_chats.id, number: 1, messages_count: 2) }
  let!(:empty_chat) { create(:chat, application_id: app_with_chats.id, number: 2, messages_count: 0) }
  let!(:message1) { create(:message, chat_id: chat.id, number: 1) }
  let!(:message2) { create(:message, chat_id: chat.id, number: 2) }

  # Test Suite for GET /api/v1/applications/:application_token/chats/:chat_number/messages
  describe "GET /api/v1/applications/:application_token/chats/:chat_number/messages" do
    context "when there are records" do
      before { get "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages" }
      
      it "returns all messages" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success")
        expect(json["data"].size).to eq(2)  
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
    
    context "when there are no messages" do
      before {get "/api/v1/applications/#{app_with_chats.token}/chats/#{empty_chat.number}/messages"}
      
      it "returns no messages found" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success") 
        expect(json["data"].size).to eq(0) 
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
  end

  # Test Suite for GET /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  describe "GET /api/v1/applications/:application_token/chats/:chat_number/messages/:number" do
    context "when the record is found" do
      before {get "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/#{message1.number}"}
      
      it "returns the message" do
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success") 
        expect(json["data"]["number"]).to eq(message1.number) 
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
    
    context "when the record isn't found" do
      before {get "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/0"}
      
      it "returns status code 404" do
        expect(response).to have_http_status(404) 
      end
    end
  end
  
  # Test Suite for POST /api/v1/applications/:application_token/chats/:chat_number/messages
  describe "POST /api/v1/applications/:application_token/chats/:chat_number/messages" do
    
    context "when the message is valid" do
      before {post "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages", params: {body: "my message body"}}
      
      it "returns the message number" do
        json = JSON.parse(response.body)
        expect(json["message_number"]).not_to be(nil)
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
    
    context "when the message not valid" do
      # empty body
      before {post "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages", params: {body: ""}}
      
      it "returns status code 400" do
        expect(response).to have_http_status(400) 
      end
    end
  end
  
  # Test Suite for PUT /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  describe "PUT /api/v1/applications/:application_token/chats/:chat_number/messages/:number" do
    context "when the message is valid" do
      let(:msg_body) { {body: "my message body"} }
      before {put "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/#{message1.number}", params: msg_body}
      
      it "returns the message number" do
        json = JSON.parse(response.body)
        expect(json["data"]["body"]).to eq(msg_body[:body])
      end
      
      it "returns status code 200" do
        expect(response).to have_http_status(200) 
      end
    end
    
    context "when the message not valid" do
      # empty body
      before {put "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/#{message1.number}", params: {body: ""}}
      
      it "returns status code 422" do
        expect(response).to have_http_status(422) 
      end
    end
  end

  # Test Suite for DELETE /api/v1/applications/:application_token/chats/:chat_number/messages/:number
  describe "DELETE /api/v1/applications/:application_token/chats/:chat_number/messages/:number" do
    context "when the record exists" do
      before {delete "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/#{message1.number}"}

      it "returns status code 204" do
        expect(response).to have_http_status(204) 
      end
    end
    
    context "when the record doesn't exist" do
      before {delete "/api/v1/applications/#{app_with_chats.token}/chats/#{chat.number}/messages/0"}
  
      it "returns status code 404" do
        expect(response).to have_http_status(404) 
      end
    end
  end
end