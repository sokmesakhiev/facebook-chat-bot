class Aggregation < ActiveRecord::Base
  belongs_to :bot

  validates :result, presence: true
  validates :bot, presence: true
  
  validates_numericality_of :score_from
  validates_numericality_of :score_to, :greater_than_or_equal_to => :score_from

end
