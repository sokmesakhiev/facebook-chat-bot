require 'rails_helper'

shared_examples_for 'Questions::FacebookParameterizableConcern' do
  let(:model) { described_class } # the class that includes the concern

  describe 'parameter template' do
    let!(:bot) { create(:bot) }
    let!(:question) { create(model.to_s.underscore.to_sym, bot: bot) }
    let!(:choice) { create(:choice, question: question) }

    context 'text_template' do
      let(:text_template_params){
        {
          'message' => {
            'text' => question.label,
            'metadata' => 'DEVELOPER_DEFINED_METADATA'
          }
        }
      }

      it { expect(question.send(:text_template)).to eq(text_template_params) }
    end

    context 'options_template' do
      let(:options_template_params) {
        {
          'message' => {
            'attachment' => {
              'type' => 'template',
              'payload' => {
                'template_type' => 'button',
                'text' => question.label,
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

      it { expect(question.send(:options_template)).to eq(options_template_params) }
    end

    context 'generic_template' do
      let(:generic_template_params){
        {
          "message" => {
            "attachment" => {
              "type" => "template",
              "payload" => {
                "template_type" => "generic",
                "elements" => [
                  {
                    "title" => question.label,
                    "image_url" => FileUtil.image_url(question.bot, question.media_image),
                    "subtitle" => question.description,
                    "buttons" => [
                      {
                        'type' => 'postback',
                        'title' => choice.label,
                        'payload' => choice.name
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      }

      it { expect(question.send(:generic_template)).to eq(generic_template_params) }
    end
  end
end
