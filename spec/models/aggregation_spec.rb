# == Schema Information
#
# Table name: aggregations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  score_from :integer
#  score_to   :integer
#  result     :string(255)
#  bot_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Aggregation, type: :model do
  it { is_expected.to belong_to(:bot) }

  it { is_expected.to validate_presence_of(:result) }
  it { is_expected.to validate_presence_of(:bot) }

  it { is_expected.to validate_numericality_of(:score_from) }
  it { is_expected.to validate_numericality_of(:score_to) }
end
