class Chat < ApplicationRecord
  # Associations
  belongs_to :application
  has_many :messages, dependent: :destroy
  
  # Validations
  validates :number, presence: true
  
  attribute :number, :integer
  attribute :messages_count, :integer, default: 0
end
