module BotHelper
  def survey_control(question)
    content_tag :div, class: 'form-group' do
      question.html_tag.html_safe
    end
  end
end
