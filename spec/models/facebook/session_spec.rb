require 'rails_helper'

RSpec.describe Facebook::Session do
  let!(:user_session_id) { '1612943458742093' }
  let!(:page_id) { '1512165178836125' }

  let!(:bot) { create(:bot, facebook_page_id: page_id) }
  
  let!(:session) { Facebook::Session.new(user_session_id, page_id) }

  context '.send_typing_on' do
    let!(:bot) { create(:bot) }
    let!(:session) { Facebook::Session.new('1612943458742093', bot.facebook_page_id) }
    let!(:params) {
      {
        'access_token' => bot.facebook_page_access_token,
        'recipient' => {
          'id' => session.user_session_id
        },
        'sender_action' => 'typing_on'
      }
    }

    it {
      expect(Facebook::Client).to receive(:send_api).with(params)

      session.send_typing_on
    }
  end

  context '.send_text' do
    let!(:bot) { create(:bot) }
    let!(:session) { Facebook::Session.new('1612943458742093', bot.facebook_page_id) }
    let(:params) {
      {
        'access_token' => bot.facebook_page_access_token,
        'recipient' => {
          'id' => session.user_session_id
        },
        'message' => {
          'text' => 'Hello world!',
          'metadata' => 'DEVELOPER_DEFINED_METADATA'
        }
      }
    }

    it {
      expect(Facebook::Client).to receive(:send_api).with(params)

      session.send_text 'Hello world!'
    }
  end

  context '.send_question' do
    let(:user_session_id) { '1612943458742093' }
    let(:page_id) { '1512165178836125' }

    context 'text field' do
      # let!(:bot) { create(:bot, facebook_page_id: page_id) }
      # let(:session) { Facebook::Session.new('1612943458742093', page_id) }
      let(:question) { create(:question, :text) }
      let!(:params) { Hash.new }

      before(:each) do
        allow(question).to receive(:to_fb_params).and_return(params)
      end

      it {
        expect(Facebook::Client).to receive(:send_api).with(params.merge("access_token"=>"aabbccdd", 'recipient' => {
          'id' => user_session_id
        }))

        session.send_question(question)
      }
    end

    context 'select_one field' do
      let(:question) { create(:question, :select_one) }
      let!(:choice) { create(:choice, question: question) }
      let!(:params) { Hash.new }

      before(:each) do
        allow(question).to receive(:to_fb_params).and_return(params)
      end

      it {
        expect(Facebook::Client).to receive(:send_api).with(params.merge("access_token"=>"aabbccdd", 'recipient' => {
          'id' => user_session_id
        }))

        session.send_question(question)
      }
    end
  end
end
