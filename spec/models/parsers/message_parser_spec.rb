require 'rails_helper'

RSpec.describe Parsers::MessageParser do
  context '.parse' do
    context 'postback messaging' do
      let(:messaging_event) {
        {
          "sender"=>{"id"=> "123456"},
          "recipient"=>{"id"=>"123456"},
          "timestamp"=>"201805294550",
          "postback"=>{
            "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
            "seq"=>570026, 
            "payload"=>"first_welcome"
          }
        }
      }

      it { expect(Parsers::MessageParser.parse(messaging_event)).to be_a_kind_of(Messages::PostbackMessage) }
    end

    context 'media messaging' do
      let(:messaging_event) {
        {
          "sender"=>{"id"=> "123456"},
          "recipient"=>{"id"=>"123456"},
          "timestamp"=>"201805294550",
          "message"=>{
            "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
            "seq"=>570026, 
            "attachments"=>[{
              "type"=>"image/audio", 
              "payload"=>{"url"=>"https://cdn.fbsbx.com/v/t59.3654-21/33417656_2255962251095772_5933083726958297088_n.mp4/audioclip-1527496025000-3136.mp4?_nc_cat=0&oh=b1df6937b4a8a3d0ddc46a63e138942d&oe=5B0D6C37"}
            }]
          }
        }
      }

      it { expect(Parsers::MessageParser.parse(messaging_event)).to be_a_kind_of(Messages::MediaMessage) }
    end

    context 'text messaging' do
      let(:messaging_event) {
        {
          "sender"=>{"id"=> "123456"},
          "recipient"=>{"id"=>"123456"},
          "timestamp"=>"201805294550",
          "message"=>{
            "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
            "seq"=>570026,
            "text"=>"Hello world!"
          }
        }
      }

      it { expect(Parsers::MessageParser.parse(messaging_event)).to be_a_kind_of(Messages::TextMessage) }
    end

    context 'unknown messaging' do
      let(:messaging_event) {
        {
          "sender"=>{"id"=> "123456"},
          "recipient"=>{"id"=>"123456"},
          "timestamp"=>"201805294550",
          "unknown"=>{
            "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
            "seq"=>570026,
            "text"=>"Hello world!"
          }
        }
      }

      it { expect { Parsers::MessageParser.parse(messaging_event) }.to raise_error(StandardError, /Unknown messaging event/) }
    end
  end

end
