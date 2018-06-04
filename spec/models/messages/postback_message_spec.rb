require 'rails_helper'

RSpec.describe Messages::TextMessage do
  context 'parse text messaging' do
    let(:messaging_event) {
      {
        "sender"=>{"id"=> "123456"},
        "recipient"=>{"id"=>"112233"},
        "timestamp"=>201805294550,
        "postback"=>{
          "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
          "seq"=>570026,
          "payload"=>"first_welcome"
        }
      }
    }

    it { expect(Messages::PostbackMessage.new(messaging_event).value).to eq("first_welcome") }
    it { expect(Messages::PostbackMessage.new(messaging_event).user_session_id).to eq("123456") }
    it { expect(Messages::PostbackMessage.new(messaging_event).page_id).to eq("112233") }
    it { expect(Messages::PostbackMessage.new(messaging_event).timestamp).to eq(201805294550) }
  end

end
