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
  before(:each) do
    @bot = create(:bot)
    @question = create(:select_one_question)
    @choice = create(:choice, question: @question)
  end

  describe '#label_element' do
    context 'without media_image' do
      it { expect(@question.label_element).to eq("\n      <div class='field-name'>\n        <span class='text-danger'> * </span><label for=#{@question.name}>#{@question.label}</label>\n      </div>\n    ") }
    end

    context 'with media_image' do
      before { @question.media_image = "test.png" }
      it { expect(@question.label_element).to eq(nil) }
    end
  end

  describe '#html_element' do
    let(:select_one_element) {
      "\n        <div class='radio'>\n          <label><input type='radio' name='choice' value='choice'>label</label>\n        </div>\n      "
    }

    let(:card_element) {
      "\n      <div class='card'>\n        <img class='card-img-top' src='#{FileUtil.image_url(@question.bot, @question.media_image)}' alt='Card image cap'>\n        <div class='card-body carousel-title'>\n          <h5 class='card-title'></h5>\n          <p class='card-text'></p>\n        </div>\n        <ul class='list-group list-group-flush card-list'>\n          \n        <li class='list-group-item'>label</li>\n      \n        </ul>\n      </div>\n    "
    }
    context 'without media image' do
      it{ expect(@question.html_element).to eq(select_one_element)  }
    end

    context 'with media image' do
      before { @question.media_image = "test.png" }
      it{ expect(@question.html_element).to eq(card_element) }
    end
  end

  describe '#to_fb_params' do

    let(:button_template_params) {
      {
        'message' => {
          'attachment' => {
            'type' => 'template',
            'payload' => {
              'template_type' => 'button',
              'text' => @question.label,
              'buttons' => [
                {
                  'type' => 'postback',
                  'title' => 'label',
                  'payload' => 'choice'
                }
              ]
            }
          }
        }
      }
    }

    let(:generic_template_params){
      {
        "message" => {
          "attachment" => {
            "type" => "template",
            "payload" => {
              "template_type" => "generic",
              "elements" => [
                 {
                  "title" => @question.label,
                  "image_url" => FileUtil.image_url(@question.bot, @question.media_image),
                  "subtitle" => @question.description,
                  "buttons" => [
                      {
                        'type' => 'postback',
                        'title' => @choice.label,
                        'payload' => @choice.name
                      }
                    ]
                  }
                ]
            }
          }
        }
      }
    }

    context 'without media image' do
      it { expect(@question.to_fb_params).to eq(button_template_params) }
    end

    context 'with media image' do
      before { @question.media_image = "test.png" }
      it { expect(@question.to_fb_params).to eq(generic_template_params) }
    end

  end

end
