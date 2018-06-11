require 'rails_helper'

RSpec.describe UserResponse do
  it { is_expected.to belong_to(:question) }

  context '#after create' do
    let!(:bot) { create(:bot) }

    before(:each) do
      allow(bot).to receive(:authorized_spreadsheet?).and_return(true)
    end

    it 'should add a job to user response worker' do
      expect {
        UserResponse.create(bot: bot, user_session_id: '123', question_id: 1, value: 'yes')
      }.to change(UserResponseWorker.jobs, :size).by(1)
    end
  end
end
