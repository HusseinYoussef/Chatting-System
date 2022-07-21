class Chat < ApplicationRecord
  # Associations
  belongs_to :application
  has_many :messages, dependent: :destroy

  attribute :number, :integer
  attribute :messages_count, :integer, default: 0
end
