# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  bot_id         :integer
#  type           :string(255)
#  select_name    :string(255)
#  name           :string(255)
#  label          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#  required       :boolean          default(FALSE)
#  uuid           :string(255)
#

require 'rails_helper'

RSpec.describe Questions::TextQuestion do
  context 'get' do
    let(:question) { create(:text_question) }

    let!(:fb_params) {
      {
        'message' => {
          'text' => question.label,
          'metadata' => 'DEVELOPER_DEFINED_METADATA'
        }
      }
    }

    it { expect(question.to_fb_params).to eq(fb_params) }
  end
end
