require 'rails_helper'

RSpec.describe Condition do
  context '#matched?' do
    let!(:bot) { create(:bot) }
    let!(:q1) { create(:question, :text, name: 'q1', bot: bot) }
    let!(:respondent) { create(:respondent, bot: bot) }
    let!(:survey) { create(:survey, respondent: respondent, question: q1, value: 'bar')}

    context 'return false if relevant question is not matched' do
      let(:condition) { Condition.new field: 'q1', operator: '=', value: 'foo' }

      it { expect(condition.matched? respondent).to eq(false) }
    end

    context "return true if relevant question is matched" do
      let(:condition) { Condition.new field: 'q1', operator: '=', value: 'bar' }

      it { expect(condition.matched? respondent).to eq(true) }
    end
  end
end
