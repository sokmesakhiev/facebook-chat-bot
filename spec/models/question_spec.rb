# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  bot_id         :integer
#  type           :string(255)
#  select_name    :string(255)
#  name           :string(255)
#  label          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#  required       :boolean          default(FALSE)
#  uuid           :string(255)
#

require 'rails_helper'
require Rails.root.join 'spec/models/concerns/questions/facebook_parameterizable_concern_spec.rb'

RSpec.describe Question do
  it_behaves_like 'Questions::FacebookParameterizableConcern'

  it { is_expected.to belong_to(:bot) }
  it { is_expected.to have_many(:choices).dependent(:destroy) }
  it { is_expected.to have_many(:respondents).with_foreign_key(:current_question_id).dependent(:nullify) }
  it { is_expected.to have_many(:surveys).dependent(:nullify) }

  # https://github.com/thoughtbot/shoulda-matchers/issues/450
  it '#validate uniqueness' do
    bot = create(:bot)
    Question.create(name: 'username', bot_id: bot.id)

    expect(validate_uniqueness_of(:name).scoped_to(:bot_id).case_insensitive)
  end

  describe 'match?' do
    let(:question) { create(:question, :text) }
    let(:respondent) { create(:respondent) }
    let(:condition) { Condition.new field: 'foo', operator: '=', value: '2' }

    context 'matched?' do
      let(:user_response) { build(:survey, respondent: respondent, question: question, value: '2')}
      
      before(:each) do
        allow(Survey).to receive(:last_response).with(respondent, question).and_return(user_response)
      end

      it { expect(question.matched?(respondent, condition)).to eq(true) }
    end

    context 'dones not matched?' do
      context 'no special character' do
        let(:user_response) { build(:survey, respondent: respondent, question: question, value: '1')}

        before(:each) do
          allow(Survey).to receive(:last_response).with(respondent, question).and_return(user_response)
        end

        it { expect(question.matched?(respondent, condition)).to eq(false) }
      end

      context 'contain quote(single or double) character' do
        let(:user_response) { build(:survey, respondent: respondent, question: question, value: "it's \" me")}

        before(:each) do
          allow(Survey).to receive(:last_response).with(respondent, question).and_return(user_response)
        end

        it { expect(question.matched?(respondent, condition)).to eq(false) }
      end
    end
  end

end
