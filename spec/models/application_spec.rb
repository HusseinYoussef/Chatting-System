require 'rails_helper'

RSpec.describe Application, type: :model do
  # Associations
  
  # Validations
  it { should validate_presence_of(:name) }
end
