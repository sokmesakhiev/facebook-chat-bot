require 'rails_helper'

RSpec.describe BotSpreadsheet do
  context '#import' do
    let(:bot) { create(:bot) }
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.xlsx'), 'application/vnd.ms-excel') }
    let(:bot_spreadsheet) { BotSpreadsheet.new(bot) }

    it 'should SurveySpreadsheet and ChoicesSpreadsheet receive import' do
      expect_any_instance_of(Spreadsheets::ChoicesSpreadsheet).to receive(:import).with(instance_of(Roo::Excelx))
      expect_any_instance_of(Spreadsheets::SurveySpreadsheet).to receive(:import).with(instance_of(Roo::Excelx))

      bot_spreadsheet.import(file, 'xlsx')
    end
  end
end
