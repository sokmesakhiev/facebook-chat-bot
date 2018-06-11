require 'rails_helper'

RSpec.describe Facebook::Client do
  context '.send_api' do
    context 'success with return 200' do
      let(:params) {
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
          
          response = Facebook::Client.send_api params

          expect(response.code).to eq(200)
        end
      }
    end

    context 'failed with return 400' do
      let(:params) {
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
          response = Facebook::Client.send_api(params)

          expect(response.code).to eq(400)
        end
      end
    end
  end
end
