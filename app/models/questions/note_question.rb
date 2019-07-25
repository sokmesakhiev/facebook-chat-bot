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

class Questions::NoteQuestion < Question
  def kind
    :note
  end

  def html_tag
    media_image ? card_tag : bullet_tag
  end

  def to_fb_params
    media_image ? to_fb_generic_template : super
  end

  private
  def card_tag
    "
      <div class='card'>
        <img class='card-img-top' src='#{FileUtil.image_url(bot, media_image)}' alt='Card image cap'>
        <ul class='list-group list-group-flush card-list'>
          #{bullet_tag}
        </ul>
      </div>
    "
  end

end
