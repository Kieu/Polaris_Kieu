class UserMailer < ActionMailer::Base
  default from: Settings.mailer.default_from

  def send_password user, password
    @user = user
    if user['role_id'] == Settings.role.CLIENT
      @company = Client.find(user['company_id']).client_name
    else
      @company = Agency.find(user['company_id']).agency_name
    end
    @password = password
    mail(to: user['email'], subject: Settings.mailer.send_password_subject) do |format|
      format.html
      format.text
    end
  end
end