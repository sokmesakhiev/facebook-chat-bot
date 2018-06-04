module BotHelper
  def survey_control(question)
    content_tag :div, class: 'form-group' do
      question.html_template.html_safe
    end
  end
end
