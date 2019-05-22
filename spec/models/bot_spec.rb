# == Schema Information
#
# Table name: bots
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  user_id                    :integer
#  facebook_page_id           :string(255)
#  facebook_page_access_token :string(255)
#  google_access_token        :string(255)
#  google_token_expires_at    :datetime
#  google_refresh_token       :string(255)
#  google_spreadsheet_key     :string(255)
#  google_spreadsheet_title   :string(255)
#  published                  :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  restart_msg                :string(255)
#  greeting_msg               :text
#

require 'rails_helper'

RSpec.describe Bot do
  it { is_expected.to have_many(:questions) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to belong_to(:user) }

  describe '#import' do
    let(:bot) { create(:bot) }
    let(:spreadsheet_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.xlsx'), 'application/vnd.ms-excel') }
    let(:zip_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'survey.zip'), 'application/zip') }
    let(:invalid_zip_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'invalid_name.zip'), 'application/zip') }

    let(:file_parser) { FileParser.new(bot) }

    before(:each) do
      allow(FileParser).to receive(:for).with(bot).and_return(file_parser)
      allow(file_parser).to receive(:import).with(spreadsheet_file).and_return(nil)
      allow(file_parser).to receive(:import).with(zip_file).and_return(nil)
      allow(file_parser).to receive(:import).with(invalid_zip_file).and_return(nil)
    end

    it 'should clear its belongs questions' do
      expect(bot.questions).to receive(:destroy_all)

      bot.import(spreadsheet_file)
    end

    it 'should add a job to worker' do
      expect {
        bot.import(spreadsheet_file)
      }.to change(Bots::ImportHeaderWorker.jobs, :size).by(1)
    end
    context 'with xls file' do
      it 'should FileParser receive import' do
        expect(file_parser).to receive(:import).with(spreadsheet_file)

        bot.import(spreadsheet_file)
      end
    end

    context 'with zip file' do
      it 'should FileParser receive import' do
        expect(file_parser).to receive(:import).with(zip_file)

        bot.import(zip_file)
      end
    end
  end

end
