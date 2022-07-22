FactoryBot.define do
    factory :application do
      name { Faker::Lorem.characters(number: 5) }
      token { Faker::Crypto.md5 }
      chats_count { 0 }
    end
end