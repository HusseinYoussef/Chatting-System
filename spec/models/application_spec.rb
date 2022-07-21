require 'rails_helper'

RSpec.describe Application, type: :model do
  # Associations
  it { should have_many(:chats).dependent(:destroy) } 
  
  # Validations
  it { should validate_presence_of(:name) }
end
