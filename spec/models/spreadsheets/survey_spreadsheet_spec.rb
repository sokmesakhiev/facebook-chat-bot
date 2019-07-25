require 'rails_helper'

RSpec.describe Spreadsheets::SurveySpreadsheet do
  let(:bot) { create(:bot) }
  let(:survey_spreadsheet) { Spreadsheets::SurveySpreadsheet.new(bot) }
  let(:row) { {'name' => 'name', 'label' => 'Name', 'type' => 'text', 'relevant' => "${q1}='no'" } }

  context '#process' do
    it 'add a question to bot' do
      survey_spreadsheet.process(row)

      expect(bot.questions.size).to eq(1)
    end

    context 'relevant expression' do
      let(:condition1) { Condition.new(field: 'q1', operator: '=', value: 'no') }
      let(:expression) { Expressions::OrExpression.new([condition1]) }

      it 'should call from_xlsform_relevant of Expression' do
        expect(Expression).to receive(:from_xlsform_relevant).with(row['relevant']).once
        expect(Parsers::QuestionParser).to receive(:parse).with('text').once

        survey_spreadsheet.process(row)
      end
    end
      
  end
end
