# == Schema Information
#
# Table name: surveys
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  value         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  respondent_id :integer
#

require 'rails_helper'

RSpec.describe Survey do
  it { is_expected.to belong_to(:respondent) }

  context '#after create' do
    let!(:respondent) { create(:respondent) }

    before(:each) do
      allow(respondent.bot).to receive(:authorized_spreadsheet?).and_return(true)
    end

    it 'should add a job to user response worker' do
      expect {
        Survey.create(respondent: respondent, question: respondent.question, value: 'yes')
      }.to change(UserResponseWorker.jobs, :size).by(1)
    end
  end
end
