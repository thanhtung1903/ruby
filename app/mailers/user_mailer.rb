# use to send in mail
class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    @greeting = t "mailer.user_mailer.acc_activation.greeting"
    mail to: @user.email, subject: t("mailer.user_mailer.acc_activation.sub")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("mailer.user_mailer.password_reset.sub")
  end
end
