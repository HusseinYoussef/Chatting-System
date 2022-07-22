class Chat < ApplicationRecord
  after_commit :create_chat_msg_counter, on: :create
  after_commit :delete_chat_msg_counter, on: :destroy

  # Associations
  belongs_to :application
  has_many :messages, dependent: :destroy
  
  # Validations
  validates :number, presence: true
  
  attribute :number, :integer
  attribute :messages_count, :integer, default: 0
  
  private

  def chat_msg_counter_key
    "#{self.application.token}_#{self.number}"
  end

  def create_chat_msg_counter
    $redis.set(chat_msg_counter_key, 0)
  end
  
  def delete_chat_msg_counter
    $redis.del(chat_msg_counter_key)
  end
end
