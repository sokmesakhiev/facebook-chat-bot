# == Schema Information
#
# Table name: respondents
#
#  id                  :integer          not null, primary key
#  user_session_id     :string(255)
#  current_question_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bot_id              :integer
#  version             :integer
#  state               :string(255)
#

require 'rails_helper'

RSpec.describe Respondent do
  it { is_expected.to belong_to(:question).with_foreign_key(:current_question_id) }
  it { is_expected.to belong_to(:bot) }
  it { is_expected.to have_many(:surveys) }

  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:bot) }
  it { is_expected.to validate_presence_of(:version) }
end
