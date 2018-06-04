require 'rails_helper'

RSpec.describe Messages::MediaMessage do
  context 'parse media messaging' do
    let(:messaging_event) {
      {
        "sender"=>{"id"=> "123456"},
        "recipient"=>{"id"=>"112233"},
        "timestamp"=>201805294550,
        "message"=>{
          "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
          "seq"=>570026, 
          "attachments"=>[{
            "type"=>"image/audio", 
            "payload"=>{"url"=>"https://chatbot.ilabsea.org/foo.mp4"}
          }]
        }
      }
    }

    it { expect(Messages::MediaMessage.new(messaging_event).value).to eq("https://chatbot.ilabsea.org/foo.mp4") }
    it { expect(Messages::MediaMessage.new(messaging_event).user_session_id).to eq("123456") }
    it { expect(Messages::MediaMessage.new(messaging_event).page_id).to eq("112233") }
    it { expect(Messages::MediaMessage.new(messaging_event).timestamp).to eq(201805294550) }
  end
end
