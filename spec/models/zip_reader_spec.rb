require "rails_helper"

RSpec.describe ZipReader do
  before(:each) do
    @bot = create(:bot)
    @survey_file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.xlsx'), 'application/vnd.ms-excel')
    @zip_file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.zip'), 'application/zip')
    @invalid_zip_file = Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'invalid_name.zip'), 'application/zip')
    @zipReader = ZipReader.for(@bot)
  end

  describe '#import' do
    context 'with valid file' do
      it 'should import the spreadsheet file' do
        expect(@zipReader).to receive(:import_spreadsheet).with('survey.xlsx')
        @zipReader.import(@zip_file.path)
      end
    end

    context 'with invalid file' do
      it 'should raise error' do
        expect { @zipReader.import(@invalid_zip_file.path) }.to raise_error("Invalid survey file")
      end
    end
  end

  describe '#extract_file' do
    it { expect(@zipReader.extract_file(@zip_file.path).length).to eq 2 }
  end

  describe '#destination_file_path' do
    it { expect(@zipReader.destination_file_path('survey.xls')).to eq "#{Rails.root}/public/upload/survey/bot_#{@bot.id}/survey.xls"}
  end

  describe '#destination_directory_path' do
    it { expect(@zipReader.destination_directory_path).to eq "#{Rails.root}/public/upload/survey/bot_#{@bot.id}"}
  end

end
