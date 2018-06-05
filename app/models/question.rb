# == Schema Information
#
# Table name: questions
#
#  id             :integer          not null, primary key
#  bot_id         :integer
#  question_type  :string(255)
#  select_name    :string(255)
#  name           :string(255)
#  label          :string(255)
#  relevant_id    :integer
#  operator       :string(255)
#  relevant_value :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Question < ApplicationRecord
  belongs_to :bot
  belongs_to :relevant, class_name: 'Question', foreign_key: 'relevant_id'
  has_many :choices, dependent: :destroy
  has_many :question_users, foreign_key: :current_question_id, dependent: :destroy
  has_many :user_responses, dependent: :destroy

  validates :name, uniqueness: { case_sensitive: false, scope: :bot_id }

  QUESTION_FIRST_WELCOME = 'first_welcome'

  def self.types
    %w(Text Integer Decimal Date SelectOne SelectMultiple)
  end

  def kind
    raise 'You have to implemented in sub-class'
  end

  def html_element
    "<input id='#{name}' name='#{name}' type=#{kind} class='form-control' />"
  end

  def html_template
    "
      <label for=#{name}>#{label}</label>
      #{html_element}
    "
  end

  def to_fb_params(user_session_id)
    {
      'recipient' => {
        'id' => user_session_id
      },
      'message' => {
        'text' => label,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      }
    }
  end

  def has_relevant?
    relevant.present?
  end

  def add_relevant(relevant)
    return unless relevant.present?

    relevant_field = relevant[/\$\{(\w+)\}/, 1]
    relevant_question = Question.where(bot_id: bot.id).find_by(name: relevant_field)
    
    if relevant_question
      params = {
        relevant_id: relevant_question.id,
        operator: relevant[/(\>\=|\<\=|\!\=|[\+\-\*\>\<\=\|]|div|or|and|mod|selected)/, 1],
        relevant_value: relevant[/[‘|'|"](\w+)[’|'|"]/, 1]
      }
      params[:operator] = '==' if params[:operator] == '='

      update_attributes(params)
    end
  end
end
