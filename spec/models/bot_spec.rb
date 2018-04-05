require 'rails_helper'

RSpec.describe Bot do
  it { is_expected.to have_many(:questions) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:user) }
end
