Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'v1' do
      resources :applications, param: :token, only: [:index, :show, :create, :update] do
        resources :chats, param: :number do
          resources :messages, param: :number

          # Search endpoint
          post '/messages/search' => 'messages#search'
        end
      end
    end
  end
end
