require 'rails_helper'

RSpec.describe UserResponse do
  it { is_expected.to belong_to(:question) }

  it '#after create' do
    expect {
      UserResponse.create(user_session_id: '123', question_id: 1, value: 'yes')
    }.to change(UserResponseWorker.jobs, :size).by(1)
  end
end
