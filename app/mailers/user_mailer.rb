class UserMailer < ActionMailer::Base
  default :from => "support@ipartymobile.com"

  def registration_activation(user , url)
    @user = user
    @url = url

    mail(:from => "SocialScoresAPI.com <no-reply@ipartymobile.com>", :to => "#{user.name} <#{user.email}>", :subject => "Please activate your account.")
  end

  def password_recovery(user , url)
    @user = user
    @url = url

    mail(:from => "SocialScoresAPI.com <no-reply@ipartymobile.com>", :to => "#{user.name} <#{user.email}>", :subject => "Lost Password.")
  end
end