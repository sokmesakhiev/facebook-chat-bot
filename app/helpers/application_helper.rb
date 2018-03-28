module ApplicationHelper
  def css_id_name
    prefix = params['controller'].downcase.split('/').join('-')
    subfix = params['action']

    "#{prefix}-#{subfix}"
  end

  def survey_control(question)
    case question.question_type
    when 'text'
      content_tag :div, class: 'form-group' do
        "
          #{label_tag(question.name, question.label)}
          #{text_field_tag(question.name, '', class: 'form-control')}
        ".html_safe
      end
    when 'integer'
      content_tag :div, class: 'form-group' do
        "
          #{label_tag(question.name, question.label)}
          #{number_field_tag(question.name, '', class: 'form-control')}
        ".html_safe
      end
    when 'date'
      content_tag :div, class: 'form-group' do
        "
          #{label_tag(question.name, question.label)}
          #{date_field_tag(question.name, '', class: 'form-control')}
        ".html_safe
      end
    when 'select_one'
      radios = question.choices.map do |choice|
        "
          <div class='radio'>
            <label><input type='radio' name='#{choice.name}'>#{choice.label}</label>
          </div>
        "
      end.join('')

      content_tag :div, class: 'form-group' do
        "
          #{label_tag(question.name, question.label)}
          #{radios}
        ".html_safe
      end
    else
      checkboxes = question.choices.map do |choice|
        "
          <div class='checkbox'>
            <label><input type='checkbox' value='#{choice.name}'>#{choice.label}</label>
          </div>
        "
      end.join('')

      content_tag :div, class: 'form-group' do
        "
          #{label_tag(question.name, question.label)}
          #{checkboxes}
        ".html_safe
      end
    end
  end
end
