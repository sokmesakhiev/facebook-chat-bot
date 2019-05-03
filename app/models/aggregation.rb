# == Schema Information
#
# Table name: aggregations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  score_from :integer
#  score_to   :integer
#  result     :string(255)
#  bot_id     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Aggregation < ActiveRecord::Base
  belongs_to :bot

  validates :result, presence: true
  validates :bot, presence: true
  
  validates_numericality_of :score_from
  validates_numericality_of :score_to, :greater_than_or_equal_to => :score_from

end
