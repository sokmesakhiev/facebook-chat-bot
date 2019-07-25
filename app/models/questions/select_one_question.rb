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
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  media_image    :string(255)
#  description    :text
#  required       :boolean          default(FALSE)
#  uuid           :string(255)
#

class Questions::SelectOneQuestion < Question
  def kind
    :radio
  end

  def value_of text
    choice = choices.find_by(label: text)
    choice.nil? ? text : choice.name
  end

  def html_tag
    media_image ? card_tag : "
      #{label_tag}
      #{options_tag}
    "
  end

  def label_tag
    return if media_image?
    
    super
  end

  def to_fb_params
    media_image ? generic_template : options_template
  end

end
