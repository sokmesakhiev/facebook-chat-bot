require 'rails_helper'

RSpec.describe Spreadsheets::ChoicesSpreadsheet do
  let(:bot) { create(:bot) }
  let(:choices_spreadsheet) { Spreadsheets::ChoicesSpreadsheet.new(bot) }

  context '#process' do
    let!(:question) { create(:question, :select_one, bot: bot, select_name: 'sex') }
    let(:row) { {'list_name' => 'sex', 'name' => 'male', 'label' => 'Male'} }
    
    it 'add a choice to question' do
      choices_spreadsheet.process(row)

      expect(question.reload.choices.size).to eq(1)
    end
  end
end
