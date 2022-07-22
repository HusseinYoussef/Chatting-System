Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'v1' do
      resources :applications, param: :token, only: [:index, :show, :create, :update] do
        resources :chats, param: :number, only: [:index, :show, :create, :update, :destroy] do
          resources :messages, param: :number, only: [:index, :show, :create, :update]
        end
        
        # Search endpoint
        post '/chats/:number/search' => 'chats#search'
      end
    end
  end
end
