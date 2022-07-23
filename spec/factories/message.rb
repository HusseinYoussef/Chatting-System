FactoryBot.define do
    factory :message do
      number { 0 }
      chat_id { 0 }
      body { Faker::Quotes::Shakespeare.hamlet_quote }
    end
end