ActionMailer::Base.smtp_settings = {
  user_name: ENV["SENDGRID_USER_NAME"],
  password: ENV["SENDGRID_USER_PASSWORD"],
  domain: ENV["SENDGRID_DOMAIN"],
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}

class Mailer < ActionMailer::Base
  def send_to_user(analysed_config, model)
    @model = model
    Logger.add :mail
    Logger.add ERB.new(File.read(analysed_config.template[:reply_mail])).result(binding)

    mail(
      from: analysed_config.mail_sender,
      to: model.send(analysed_config.mail_address_attribute),
      subject: analysed_config.mail_subject
    ) do |format|
      format.html {
        render text: ERB.new(File.read(analysed_config.template[:reply_mail])).result(binding)
      }
    end
  end

  def send_to_admin(analysed_config, model)
    @model = model
    Logger.add :mail
    Logger.add ERB.new(File.read(analysed_config.template[:reply_mail])).result(binding)

    mail(
      from: analysed_config.mail_sender,
      to: analysed_config.admin_address,
      subject: analysed_config.admin_mail_subject
    ) do |format|
      format.html {
        render text: ERB.new(File.read(analysed_config.template[:admin_mail])).result(binding)
      }
    end
  end

  def write(attribute_name)
    value = @model.send(attribute_name)
    if value.is_a?(Array)
      value = value.join('、')
    end

    CGI.escapeHTML(value.to_s)
  end
end