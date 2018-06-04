require 'rails_helper'

RSpec.describe Bot do
  it { is_expected.to have_many(:questions) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:user) }

  context '#import' do
    let(:bot) { create(:bot) }
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.xlsx'), 'application/vnd.ms-excel') }
    let(:bot_spreadsheet) { BotSpreadsheet.new(bot) }

    before(:each) do
      allow(BotSpreadsheet).to receive(:for).with(bot).and_return(bot_spreadsheet)
      allow(bot_spreadsheet).to receive(:import).with(file).and_return(nil)
    end

    it 'should clear its belongs questions' do
      expect(bot.questions).to receive(:destroy_all)

      bot.import(file)
    end

    it 'should BotSpreadsheet receive import' do
      expect(bot_spreadsheet).to receive(:import).with(file)

      bot.import(file)
    end

    it 'should add a job to worker' do
      expect {
        bot.import(file)
      }.to change(Bots::ImportHeaderWorker.jobs, :size).by(1)
    end
  end
end
