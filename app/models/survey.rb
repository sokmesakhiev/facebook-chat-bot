class Survey < ApplicationRecord
  belongs_to :bot
  has_many :choices, dependent: :destroy

  validates :name, uniqueness: { scope: :bot_id }
end
