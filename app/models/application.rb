class Application < ApplicationRecord
    after_create :create_app_chats_counter
    after_commit :delete_app_chats_counter, on: :destroy

    # Associations
    has_many :chats, dependent: :destroy

    # Validations
    validates :name, presence: true

    has_secure_token :token

    attribute :name, :string
    attribute :token, :string
    attribute :chats_count, :integer, default: 0

    def increment_chats_count
        $redis.incr(app_chats_counter_key)
    end
    
    private

    def app_chats_counter_key
        self.token
    end

    def create_app_chats_counter
        $redis.set(app_chats_counter_key, 0)
        $redis.expire(app_chats_counter_key, 500)
    end

    def delete_app_chats_counter
        $redis.del(app_chats_counter_key)
    end
end
