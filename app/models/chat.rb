class Chat < ApplicationRecord
  after_create :create_chat_messages_counter
  after_commit :delete_chat_messages_counter, on: :destroy

  # Associations
  belongs_to :application, optional: true
  has_many :messages, dependent: :destroy
  
  # Validations
  validates :number, presence: true
  
  attribute :number, :integer
  attribute :application_token, :string
  attribute :messages_count, :integer, default: 0
  
  def increment_chat_messages_counter
    $redis.incr(chat_messages_counter_key)
  end

  private
  
  def chat_messages_counter_key
    "#{self.application_token}_chat#{self.number}"
  end

  def create_chat_messages_counter
    $redis.set(chat_messages_counter_key, 0)
  end
  
  def delete_chat_messages_counter
    $redis.del(chat_messages_counter_key)
  end
end
