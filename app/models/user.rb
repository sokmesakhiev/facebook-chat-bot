class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  ROLES = %w[admin operator].freeze

  has_many :bots

  validates :role, inclusion: { in: ROLES }

  def admin?
    role == 'admin'
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def self.create_from_omniauth(params)
    # user = find_or_create_by(email: params.info.email, uid: params.uid)
    # user.update({
    #   token: params.credentials.token,
    #   name: params.info.name,
    #   avatar: params.info.image
    # })
    # user
  end
end
