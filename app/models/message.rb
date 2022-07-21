class Message < ApplicationRecord
  # Associations
  belongs_to :chat, dependent: :destroy

  # Validations
  validates :number, presence: true
  validates :body, presence: true
  
  attribute :number, :integer
  attribute :body, :text
end
