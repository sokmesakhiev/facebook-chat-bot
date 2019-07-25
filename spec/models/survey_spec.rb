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

  context '.matched?' do
    let!(:respondent) { create(:respondent) }
    let(:condition1) { Condition.new field: 'q1', operator: '=', value: 'foo' }
    let(:condition2) { Condition.new field: 'q2', operator: '=', value: 'bar' }

    context 'Or expression' do
      let!(:expression) { Expressions::OrExpression.new [condition1, condition2] }

      context 'it is false if all of relevants are not matched' do
        before(:each) do
          allow(condition1).to receive(:matched?).with(respondent).and_return(false)
          allow(condition2).to receive(:matched?).with(respondent).and_return(false)
        end

        it { expect(Survey.matched? respondent, expression).to eq(false) }
      end

      context "return true if any relevants are matched" do
        before(:each) do
          allow(condition1).to receive(:matched?).with(respondent).and_return(true)
          allow(condition2).to receive(:matched?).with(respondent).and_return(false)
        end

        it { expect(Survey.matched? respondent, expression).to eq(true) }
      end
    end
    
    context 'And expression' do
      let!(:expression) { Expressions::AndExpression.new [condition1, condition2] }

      context 'it is false if any of relevants are not matched' do
        before(:each) do
          allow(condition1).to receive(:matched?).with(respondent).and_return(true)
          allow(condition2).to receive(:matched?).with(respondent).and_return(false)
        end

        it { expect(Survey.matched? respondent, expression).to eq(false) }
      end

      context "return true if all relevants are matched" do
        before(:each) do
          allow(condition1).to receive(:matched?).with(respondent).and_return(true)
          allow(condition2).to receive(:matched?).with(respondent).and_return(true)
        end

        it { expect(Survey.matched? respondent, expression).to eq(true) }
      end
    end
  end
end
