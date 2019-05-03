require 'rails_helper'

RSpec.describe FileParser do

  describe '#import' do
    let(:bot) { create(:bot) }

    let(:spreadsheet_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.xlsx'), 'application/vnd.ms-excel') }
    let(:zip_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.zip'), 'application/zip') }
    let(:invalid_zip_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'invalid_name.zip'), 'application/zip') }

    let(:bot_spreadsheet) { BotSpreadsheet.new(bot) }
    let(:zip_reader) { ZipReader.new(bot) }

    let(:file_parser) { FileParser.new(bot) }

    before(:each) do
      allow(BotSpreadsheet).to receive(:for).with(bot).and_return(bot_spreadsheet)
      allow(ZipReader).to receive(:for).with(bot).and_return(zip_reader)
      allow(bot_spreadsheet).to receive(:import).with(spreadsheet_file.path, 'xlsx').and_return(nil)
      allow(zip_reader).to receive(:import).with(zip_file.path).and_return(nil)
      allow(zip_reader).to receive(:import).with(invalid_zip_file.path).and_raise("Invalid survey file")
    end

    context "with .xlsx file" do
      it 'should BotSpreadsheet receive import' do
        expect(bot_spreadsheet).to receive(:import).with(spreadsheet_file.path, 'xlsx')

        file_parser.import(spreadsheet_file)
      end
    end

    context "with .zip" do
      context "when valid survey file" do
        it 'should ZipReader receive import' do
          expect(zip_reader).to receive(:import).with(zip_file.path)

          file_parser.import(zip_file)
        end
      end

      context "when invalid survey file" do
        it 'should raise exception' do
          expect { file_parser.import(invalid_zip_file) }.to raise_error("Invalid survey file")
        end
      end
    end

  end
end
