module BotHelper
  def survey_control(question)
    case question.question_type
    when 'text'
      text_template(question)
    when 'integer', 'decimal'
      number_template(question)
    when 'date'
      date_template(question)
    when 'select_one'
      select_one_template(question)
    else
      select_many_template(question)
    end
  end

  private

  def text_template(question)
    content_tag :div, class: 'form-group' do
      "
        #{label_tag(question.name, question.label)}
        #{text_field_tag(question.name, '', class: 'form-control')}
      ".html_safe
    end
  end

  def number_template(question)
    content_tag :div, class: 'form-group' do
      "
        #{label_tag(question.name, question.label)}
        #{number_field_tag(question.name, '', class: 'form-control')}
      ".html_safe
    end
  end

  def date_template(question)
    content_tag :div, class: 'form-group' do
      "
        #{label_tag(question.name, question.label)}
        #{date_field_tag(question.name, '', class: 'form-control')}
      ".html_safe
    end
  end

  def select_one_template(question)
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
  end

  def select_many_template(question)
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
