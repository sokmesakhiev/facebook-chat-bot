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
end
