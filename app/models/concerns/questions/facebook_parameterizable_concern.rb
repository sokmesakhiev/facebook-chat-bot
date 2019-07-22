module Questions::FacebookParameterizableConcern
  extend ActiveSupport::Concern

  included do
    def to_fb_params
      media_image ? generic_template : text_template
    end

    private
    def generic_template
      {
        "message" => {
          "attachment" => {
            "type" => "template",
            "payload" => {
              "template_type" => "generic",
              "elements" => [
                 {
                  "title" => label,
                  "image_url" => FileUtil.image_url(bot, media_image),
                  "subtitle" => description,
                  "buttons" => buttons.take(3)
                  }
                ]
            }
          }
        }
      }
    end

    def options_template
      {
        'message' => {
          'attachment' => {
            'type' => 'template',
            'payload' => {
              'template_type' => 'button',
              'text' => label,
              'buttons' => buttons.take(3)
            }
          }
        }
      }
    end

    def button_template choice
      {
        'type' => 'postback',
        'title' => choice.label,
        'payload' => choice.name
      }
    end

    def text_template
      {
        'message' => {
          'text' => label,
          'metadata' => 'DEVELOPER_DEFINED_METADATA'
        }
      }
    end

    def buttons
      choices.map do |choice|
        button_template choice
      end
    end
  end
end
