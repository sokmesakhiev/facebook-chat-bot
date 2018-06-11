require 'rails_helper'

RSpec.describe SurveyService do
  let!(:user_session_id) { '1612943458742093' }
  let!(:page_id) { '1512165178836125' }

  context '#move_next' do
    let!(:bot) { create(:bot, :with_simple_surveys_and_choices, facebook_page_id: page_id) }
    let!(:session) { Facebook::Session.new(user_session_id, page_id) }

    before(:each) do
      allow(session).to receive(:send_typing_on).and_return(true)
    end

    context 'should send the first qusetion if survey is first started' do
      let(:first_question) { bot.questions.first }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow(survey_service).to receive(:next_question).with(nil).and_return(first_question)
      end

      it {
        expect(session).to receive(:send_question).with(first_question).once

        survey_service.move_next
      }
    end

    context 'should return next question of current question' do
      let(:current_question) { bot.questions.first }
      let(:next_question) { bot.questions[1] }
      let(:session) { Facebook::Session.new(user_session_id, page_id) }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow_any_instance_of(QuestionUser).to receive(:question).and_return(current_question)
        allow(survey_service).to receive(:next_question).with(current_question).and_return(next_question)
      end

      it {
        expect(session).to receive(:send_question).with(next_question).once

        survey_service.move_next
      }
    end

    context 'should finish survey if question is the last question' do
      let(:last_question) { bot.questions.last }
      let(:survey_service) { SurveyService.new(session) }

      before(:each) do
        allow_any_instance_of(QuestionUser).to receive(:question).and_return(last_question)
        allow(survey_service).to receive(:next_question).with(last_question).and_return(nil)
      end

      it {
        expect(survey_service).to receive(:finish).once

        survey_service.move_next()
      }
    end
  end

  context '#next_question' do
    let!(:bot) { create(:bot, :with_simple_surveys_and_choices, facebook_page_id: page_id) }
    let!(:session) { Facebook::Session.new(user_session_id, page_id) }

    let!(:question1) { bot.questions[0] }
    let!(:question2) { bot.questions[1] }
    let!(:question3) { bot.questions[2] }

    let!(:session) { Facebook::Session.new(user_session_id, page_id) }
    let(:survey_service) { SurveyService.new(session) }

    context 'next_question has no skip logic' do
      before(:each) do
        allow(survey_service).to receive(:skip_question).with(question2).and_return(false)
      end

      it { expect { survey_service.next_question(current_question).to eq(question2) }}
    end

    context 'next_question has skip logic' do
      before(:each) do
        allow(survey_service).to receive(:skip_question).with(question2).and_return(true)
      end

      it { expect { survey_service.next_question(current_question).to eq(question3) } }
    end
  end
end
