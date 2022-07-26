require 'rails_helper'

RSpec.describe Chat, type: :model do
  # Associations
  it { should have_many(:messages).dependent(:destroy) } 

  # Validations
  it { should validate_presence_of(:number) }
end
