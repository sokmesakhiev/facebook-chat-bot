require 'rails_helper'

RSpec.describe SurveyService do
  let!(:user_session_id) { '1612943458742093' }
  let!(:page_id) { '1512165178836125' }

  context '#move_next' do
    let!(:bot) { create(:bot, :with_required_surveys_and_choices, facebook_page_id: page_id) }
    let!(:session) { Facebook::Session.new(user_session_id, page_id) }
    let!(:respondent) { create(:respondent) }

    before(:each) do
      allow(session).to receive(:send_typing_on).and_return(true)
      allow(survey_service).to receive(:find_or_initialize_respondent).with(session).and_return(respondent)
    end

    context 'for first started conversation' do
      let(:first_question) { bot.questions.first }
      let(:second_question) { bot.questions.second }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(respondent).to receive(:question).and_return(nil)
        allow(survey_service).to receive(:next_question).with(respondent, nil).and_return(first_question)
      end

      it {
        expect(session).to receive(:send_question).with(first_question).once

        survey_service.move_next
      }
    end

    context 'should return next question of current question' do
      let(:current_question) { bot.questions.first }
      let(:second_question) { bot.questions.second }
      let(:session) { Facebook::Session.new(user_session_id, page_id) }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(respondent).to receive(:question).and_return(current_question)
        allow(survey_service).to receive(:next_question).with(respondent, current_question).and_return(second_question)
      end

      it {
        expect(session).to receive(:send_question).with(second_question).once

        survey_service.move_next
      }
    end

    context 'with required questions' do
      let(:current_question) { bot.questions.second }
      let(:third_question) { bot.questions.third }
      let(:fourth_question) { bot.questions.fourth }
      let(:session) { Facebook::Session.new(user_session_id, page_id) }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(respondent).to receive(:question).and_return(current_question)
        allow(survey_service).to receive(:next_question).with(respondent, current_question).and_return(third_question)
        allow(survey_service).to receive(:next_question).with(respondent, third_question).and_return(fourth_question)
      end

      it {
        expect(session).to receive(:send_question).with(third_question).once
        expect(session).to receive(:send_question).with(fourth_question).once

        survey_service.move_next
      }
    end

    context 'should finish survey if question is the last question' do
      let(:last_question) { bot.questions.last }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(respondent).to receive(:question).and_return(last_question)
        allow(survey_service).to receive(:next_question).with(respondent, last_question).and_return(nil)
      end

      it {
        expect(survey_service).to receive(:finish).once

        survey_service.move_next()
      }
    end

    context 'should send greeting message when the survey is finished but user response no on restart action' do
      let!(:session) { Facebook::Session.new(user_session_id, page_id, 'no') }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(survey_service).to receive(:find_or_initialize_respondent).and_return(nil)
        allow(session.bot).to receive(:message_for).with(:greeting_msg).and_return('greeting')
      end

      it { expect(session.response_text).to eq('no') }

      it {
        expect(session).to receive(:send_text).with('greeting')

        survey_service.move_next()
      }
    end
  end

  context '#next_question' do
    let!(:bot) { create(:bot, :with_simple_surveys_and_choices, facebook_page_id: page_id) }

    let!(:question1) { bot.questions[0] }
    let!(:question2) { bot.questions[1] }
    let!(:question3) { bot.questions[2] }

    let!(:session) { Facebook::Session.new(user_session_id, page_id) }
    let!(:respondent) { create(:respondent) }
    let(:survey_service) { SurveyService.new(session) }

    context 'next_question has no skip logic' do
      before(:each) do
        allow(survey_service).to receive(:skip_question).with(respondent, question2).and_return(false)
      end

      it { expect { survey_service.next_question(respondent, current_question).to eq(question2) }}
    end

    context 'next_question has skip logic' do
      let!(:respondent) { create(:respondent) }

      before(:each) do
        allow(survey_service).to receive(:skip_question).with(respondent, question2).and_return(true)
      end

      it { expect { survey_service.next_question(respondent, current_question).to eq(question3) } }
    end
  end
end
