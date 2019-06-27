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

class Questions::NoteQuestion < Question
  def kind
    :note
  end

  def html_element
    media_image ? card_element : list_element
  end

  def label_element
    return
  end

  def to_fb_params
    media_image ? to_fb_generic_template : super
  end

  private
  def list_element

    list = label.split("\n").map do |labelRow|
      "
        <div class='#{kind}'>
          <label>#{labelRow}</label>
        </div>
      "
    end.join('')
  end

  def card_element
    "
      <div class='card'>
        <img class='card-img-top' src='#{FileUtil.image_url(bot,media_image)}' alt='Card image cap'>
        <ul class='list-group list-group-flush card-list'>
          #{render_options}
        </ul>
      </div>
    "
  end

  def render_options
    list = label.split("\n").map do |labelRow|
      "
        <li class='list-group-item'>#{labelRow}</li>
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
                "subtitle" => description
                }
              ]
          }
        }
      }
    }
  end

end
