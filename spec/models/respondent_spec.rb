require 'rails_helper'

RSpec.describe Respondent do
  it { is_expected.to belong_to(:question).with_foreign_key(:current_question_id) }
  it { is_expected.to belong_to(:bot) }
  it { is_expected.to have_many(:surveys) }

  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:bot) }
  it { is_expected.to validate_presence_of(:version) }
end
