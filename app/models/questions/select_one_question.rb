class Questions::SelectOneQuestion < Question
  def kind
    :radio
  end

  def html_element
    options = choices.map do |choice|
      "
        <div class='#{kind}'>
          <label><input type='#{kind}' name='#{choice.name}' value='#{choice.name}'>#{choice.label}</label>
        </div>
      "
    end.join('')
  end

  def to_fb_params(user_session_id)
    buttons = choices.map do |choice|
      {
        'type' => 'postback',
        'title' => choice.label,
        'payload' => choice.name
      }
    end

    {
      'recipient' => {
        'id' => user_session_id
      },
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
end
