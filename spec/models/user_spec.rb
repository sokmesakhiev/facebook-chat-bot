require 'rails_helper'

RSpec.describe User do
  it { is_expected.to have_many(:bots).dependent(:destroy) }
  it { is_expected.to validate_inclusion_of(:role).in_array(%w[user admin]) }
end
