class Application < ApplicationRecord
    # Associations
    has_many :chats, dependent: :destroy

    # Validations
    validates :name, presence: true, length: {maximum: 50}

    has_secure_token :token

    attribute :name, :string
    attribute :token, :string
    attribute :chats_count, :integer, default: 0    
end
