require 'rails_helper'

RSpec.describe QuestionUser do
  it { is_expected.to belong_to(:question).with_foreign_key(:current_question_id) }
end
