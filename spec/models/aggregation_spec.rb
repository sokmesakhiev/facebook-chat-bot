require 'rails_helper'

RSpec.describe Aggregation, type: :model do
  it { is_expected.to belong_to(:bot) }

  it { is_expected.to validate_presence_of(:result) }
  it { is_expected.to validate_presence_of(:bot) }

  it { is_expected.to validate_numericality_of(:score_from) }
  it { is_expected.to validate_numericality_of(:score_to) }
end
