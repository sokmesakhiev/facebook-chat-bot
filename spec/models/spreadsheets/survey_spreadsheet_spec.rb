require 'rails_helper'

RSpec.describe Spreadsheets::SurveySpreadsheet do
  let(:bot) { create(:bot) }
  let(:survey_spreadsheet) { Spreadsheets::SurveySpreadsheet.new(bot) }

  context '#process' do
    let(:row) { {'name' => 'name', 'label' => 'Name', 'type' => 'text ' } }

    it 'add a question to bot' do
      survey_spreadsheet.process(row)

      expect(bot.questions.size).to eq(1)
    end
  end
end
