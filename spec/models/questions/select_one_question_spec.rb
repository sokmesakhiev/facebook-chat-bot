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
#  relevant_id    :integer
#  operator       :string(255)
#  relevant_value :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#  required       :boolean          default(FALSE)
#  uuid           :string(255)
#

require 'rails_helper'

RSpec.describe Questions::SelectOneQuestion do
  describe '#html_tag' do
    context 'it should call card_tag if no media image provided' do
      let(:question) { build(:select_one_question, media_image: 'abc.png') }
      
      it {
        expect(question).to receive(:card_tag).once

        question.html_tag
      }
    end

    context 'it should call options_tag if media image provided' do
      let(:question) { build(:select_one_question, media_image: nil) }
      
      it {
        expect(question).to receive(:label_tag).once
        expect(question).to receive(:options_tag).once

        question.html_tag
      }
    end
  end

  describe '#to_fb_params' do
    context 'it should call options_template if no media image provided' do
      let(:question) { build(:select_one_question, media_image: nil) }
      
      it {
        expect(question).to receive(:options_template).once

        question.to_fb_params
      }
    end

    context 'it should call generic_template if media image provided' do
      let(:question) { build(:select_one_question, media_image: 'abc.png') }
      
      it {
        expect(question).to receive(:generic_template).once

        question.to_fb_params
      }
    end
  end

end
