class Application < ApplicationRecord
    after_commit :create_app_chat_counter, on: :create

    # Associations
    has_many :chats, dependent: :destroy

    # Validations
    validates :name, presence: true

    has_secure_token :token

    attribute :name, :string
    attribute :token, :string
    attribute :chats_count, :integer, default: 0

    private

    def create_app_chat_counter
        $redis.set(self.token, 0)
    end
end
