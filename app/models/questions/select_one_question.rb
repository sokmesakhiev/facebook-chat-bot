# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  bot_id         :integer
#  type           :string(255)
#  select_name    :string(255)
#  name           :string(255)
#  label          :string(255)
#  relevant_id    :integer
#  operator       :string(255)
#  relevant_value :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#

class Questions::SelectOneQuestion < Question
  def kind
    :radio
  end

  def value_of text
    choice = choices.find_by(label: text)
    choice.nil? ? text : choice.name
  end

  def html_element
    media_image ? card_element : select_one_element
  end

  def label_element
    return if media_image?
    return super
  end

  def to_fb_params
    media_image ? to_fb_generic_template : to_fb_button_template
  end

  private
  def select_one_element
    options = choices.map do |choice|
      "
        <div class='#{kind}'>
          <label><input type='#{kind}' name='#{choice.name}' value='#{choice.name}'>#{choice.label}</label>
        </div>
      "
    end.join('')
  end

  def card_element
    "
      <div class='card'>
        <img class='card-img-top' src='#{FileUtil.image_url(bot,media_image)}' alt='Card image cap'>
        <div class='card-body carousel-title'>
          <h5 class='card-title'>#{label}</h5>
          <p class='card-text'>#{description}</p>
        </div>
        <ul class='list-group list-group-flush card-list'>
          #{render_options}
        </ul>
      </div>
    "
  end

  def render_options
    options = choices.map do |choice|
      "
        <li class='list-group-item'>#{choice.label}</li>
      "
    end.join('')
  end

  def to_fb_generic_template
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
                "buttons" => buttons_from_choices.take(3)
                }
              ]
          }
        }
      }
    }
  end

  def to_fb_button_template
    {
      'message' => {
        'attachment' => {
          'type' => 'template',
          'payload' => {
            'template_type' => 'button',
            'text' => label,
            'buttons' => buttons_from_choices.take(3)
          }
        }
      }
    }
  end

  def buttons_from_choices
    choices.map do |choice|
      {
        'type' => 'postback',
        'title' => choice.label,
        'payload' => choice.name
      }
    end
  end

end
