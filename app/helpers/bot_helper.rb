module BotHelper
  def survey_control(question)
    # question = question.becomes(Questions::CarouselQuestion) if question.media_image?
    content_tag :div, class: 'form-group' do
      question.html_template.html_safe
    end
  end
end
