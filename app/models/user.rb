class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :database_authenticatable, :lockable, :recoverable, :registerable
  # :timeoutable, and :validatable
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :token, dependent: :destroy
  has_one :configuration, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :gigs, -> { where.not(pay: nil) }, class_name: "Event"

  accepts_nested_attributes_for :token
  accepts_nested_attributes_for :configuration

  def attributes_with_custom_error_message
    [:"configuration.monthly_goal"]
  end

  def has_completed_setup?
    configuration.calendar_id.present? && self.time_zone.present?
  end

  def is_tracking_income?
    !!configuration.monthly_goal
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
