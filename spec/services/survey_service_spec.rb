require 'rails_helper'

RSpec.describe SurveyService do
  context "has no skip logic" do
    let!(:bot) { create(:bot, :with_simple_surveys_and_choices, facebook_page_id: '1512165178836125') }
    let(:survey_service) { SurveyService.new('123', '1512165178836125') }

    it '#first_question' do
      expect(survey_service.first_question.name).to eq('username')
    end

    it '#last_question?' do
      QuestionUser.create(user_session_id: '123', current_question_id: bot.questions.last.id)

      expect(survey_service.last_question?).to eq(true)
    end
  end

  context "has skip logic" do
    let!(:bot) { create(:bot, :with_skip_logic_surveys_and_choices, facebook_page_id: '1512165178836125') }
    let(:question_user_with_question1) { QuestionUser.create(user_session_id: '123', current_question_id: 1) }
    let(:user_response_like_piza) { UserResponse.create(user_session_id: '123', question_id: 1, value: 'yes') }
    let(:user_response_dose_not_like_piza) { UserResponse.create(user_session_id: '123', question_id: 1, value: 'no') }
    let(:user_response_like_cheese) { UserResponse.create(user_session_id: '123', question_id: 2, value: 'cheese,sausage') }
    let(:survey_service) { SurveyService.new('123', '1512165178836125') }

    it '#first_question' do
      expect(survey_service.first_question.id).to eq(1)
    end

    it 'returns next question as favorite_topping' do
      question_user_with_question1
      user_response_like_piza

      expect(survey_service.next_question.id).to eq(2)
    end

    it 'returns next question as favorite_cheese' do
      QuestionUser.create(user_session_id: '123', current_question_id: 2)
      user_response_like_cheese

      expect(survey_service.next_question.id).to eq(3)
    end

    it 'returns next question as thank' do
      QuestionUser.create(user_session_id: '123', current_question_id: 3)

      expect(survey_service.next_question.id).to eq(4)
    end

    it 'returns next question as thank' do
      question_user_with_question1
      user_response_dose_not_like_piza

      expect(survey_service.next_question.id).to eq(4)
    end

    it 'returns next question as nil' do
      Bot.destroy_all
      create(:bot, :with_skip_logic_surveys_and_choices, count: 3, facebook_page_id: '1512165178836125')
      question_user_with_question1
      user_response_dose_not_like_piza

      expect(survey_service.next_question).to eq(nil)
    end

    it '#last_question?' do
      QuestionUser.create(user_session_id: '123', current_question_id: 4)

      expect(survey_service.last_question?).to eq(true)
    end
  end

end
