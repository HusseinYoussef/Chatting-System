require 'elasticsearch/model'

class Message < ApplicationRecord
  # Associations
  belongs_to :chat, counter_cache: true

  # Validations
  validates :body, presence: true
  
  attribute :number, :integer
  attribute :body, :text

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks # ensures that Elasticsearch indexes are updated when a record is created or updated

  settings index: { number_of_shards: 1 } do
    mappings dynamic: false do
      indexes :chat_id, type: :integer
      indexes :number, type: :integer
      indexes :body, type: :text, analyzer: :english
    end
  end

  # Store/index only chat_id, body in elastic search
  def as_indexed_json(options = {})
    self.as_json(only: [:chat_id, :number, :body])
  end  

  def self.search(chat_id, query)
    __elasticsearch__.search(
      {
        # return only "body" and "number" fields
        _source: [:body, :number],
        query: {
          bool: {
            must: [
              { 
                match: { 
                  chat_id: chat_id 
                } 
              },{ 
                match: {
                  body: {
                    query: "*#{query}*",
                    fuzziness: "AUTO"
                  }
                } 
              }
            ]
          }
        }
      }
    )
  end
end
Message.import(force: true)
