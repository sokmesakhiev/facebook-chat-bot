require 'rails_helper'

RSpec.describe ChatbotService do
  context 'Add a job to worker when receive messaging event' do
    let!(:event) {
      {
        "sender"=>{"id"=> "123456"},
        "recipient"=>{"id"=>"112233"},
        "timestamp"=>201805294550,
        "message"=>{
          "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
          "seq"=>570026,
          "text"=>"Hello world!"
        }
      }
    }
    let(:message) { Messages::TextMessage.new(event) }

    before(:each) do
      allow(Parsers::MessageParser).to receive(:parse).with(event).and_return(message)
    end

    it {
      expect {
        ChatbotService.receive(event)
      }.to change(Bots::MessageWorker.jobs, :size).by(1)
    }
  end

  context '.send_typing_on' do
    let!(:bot) { create(:bot) }
    let!(:message_data) {
      {
        'access_token' => 'aabbccdd',
        'recipient' => {
          'id' => '1612943458742093'
        },
        'sender_action' => 'typing_on'
      }
    }

    it {
      expect(ChatbotService).to receive(:send_api).with(message_data)

      ChatbotService.send_typing_on('1612943458742093', '1512165178836125')
    }
  end

  context '.send_text' do
    let!(:bot) { create(:bot) }
    let(:message_data) {
      {
        'access_token' => 'aabbccdd',
        'recipient' => {
          'id' => '1612943458742093'
        },
        'message' => {
          'text' => 'Hello world!',
          'metadata' => 'DEVELOPER_DEFINED_METADATA'
        }
      }
    }

    it {
      expect(ChatbotService).to receive(:send_api).with(message_data)

      ChatbotService.send_text('1612943458742093', '1512165178836125', 'Hello world!')
    }
  end

  context '.send_question' do
    let(:user_session_id) { '1612943458742093' }
    let(:page_id) { '1512165178836125' }

    context 'text field' do
      let!(:bot) { create(:bot, facebook_page_id: page_id) }
      let(:question) { create(:question, :text) }
      let!(:fb_params) { Hash.new }

      before(:each) do
        allow(question).to receive(:to_fb_params).with(user_session_id).and_return(fb_params)
      end

      it {
        expect(ChatbotService).to receive(:send_api).with(fb_params.merge("access_token"=>"aabbccdd"))

        ChatbotService.send_question(user_session_id, page_id, question)
      }
    end

    context 'select_one field' do
      let!(:bot) { create(:bot, facebook_page_id: page_id) }
      let(:question) { create(:question, :select_one) }
      let!(:choice) { create(:choice, question: question) }
      let!(:fb_params) { Hash.new }

      before(:each) do
        allow(question).to receive(:to_fb_params).with(user_session_id).and_return(fb_params)
      end

      it {
        expect(ChatbotService).to receive(:send_api).with(fb_params.merge("access_token"=>"aabbccdd"))

        ChatbotService.send_question(user_session_id, page_id, question)
      }
    end
  end

  context '.send_api' do
    context 'success with return 200' do
      let(:message_data) {
        {
          'access_token' => 'aabbccdd',
          'recipient' => {
            'id' => '1612943458742093'
          },
          'sender_action' => 'typing_on'
        }
      }

      it {
        VCR.use_cassette "bot/success" do
          bot = create(:bot, :with_simple_surveys_and_choices)
          
          response = ChatbotService.send_api message_data

          expect(response.code).to eq(200)
        end
      }
    end

    context 'failed with return 400' do
      let(:message_data) {
        {
          'access_token' => 'token',
          'recipient' => {
            'id' => '1612943458742093'
          },
          'sender_action' => 'typing_on'
        }
      }

      it 'returns 400', vcr: { cassette_name: 'bot/fails' }  do
        VCR.use_cassette "bot/fails" do
          bot = create(:bot, :with_simple_surveys_and_choices, facebook_page_access_token: 'token')
          response = ChatbotService.send_api(message_data)

          expect(response.code).to eq(400)
        end
      end
    end
  end
end
