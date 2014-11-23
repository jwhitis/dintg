class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :database_authenticatable, :lockable, :recoverable, :registerable
  # :timeoutable, and :validatable
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :token, dependent: :destroy
  has_one :configuration, dependent: :destroy
  has_many :gigs, dependent: :destroy

  accepts_nested_attributes_for :token
  accepts_nested_attributes_for :configuration

  def has_completed_setup?
    configuration.monthly_goal.present?
  end

  def gigs_for_period(time_period)
    gigs.for_period(time_period)
  end

  def paid_gigs_for_period(time_period)
    gigs.paid.for_period(time_period)
  end

  def self.find_for_google_oauth2(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name

      token = user.build_token
      token.access_token = auth.credentials.token
      token.refresh_token = auth.credentials.refresh_token
      token.expires_at = Time.at(auth.credentials.expires_at).to_datetime

      config = user.build_configuration
      config.calendar_id = auth.info.email
    end
  end

end
