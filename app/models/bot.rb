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
#

class Bot < ApplicationRecord
  has_many :questions, dependent: :destroy
  belongs_to :user

  validates :name, presence: true

  def import(file)
    return unless File.exists? file.path

    questions.destroy_all

    BotSpreadsheet.for(self).import(file)

    Bots::ImportHeaderWorker.perform_async(id)
  end

  def authorized_spreadsheet?
    google_access_token.present? && google_spreadsheet_key.present?
  end

  def authorized_facebook?
    facebook_page_id.present? && facebook_page_access_token.present?
  end
end
