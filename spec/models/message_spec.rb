require 'rails_helper'

RSpec.describe Message, type: :model do
  # Associations
  it { should belong_to(:chat) } 

  # Validations
  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:body) }
end
