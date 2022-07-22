class Application < ApplicationRecord
    after_commit :create_app_chat_counter, on: :create
    after_commit :delete_app_chat_counter, on: :destroy

    # Associations
    has_many :chats, dependent: :destroy

    # Validations
    validates :name, presence: true

    has_secure_token :token

    attribute :name, :string
    attribute :token, :string
    attribute :chats_count, :integer, default: 0

    private

    def app_chat_counter_key
        self.token
    end
    
    def create_app_chat_counter
        $redis.set(app_chat_counter_key, 0)
    end
    
    def delete_app_chat_counter
        $redis.del(app_chat_counter_key)
    end
end
