#
# Sends email with the cracked password.
# TODO: add notification field to creation form to
# include email and SMS
#
class Notifications
  def mail(subject, body)
    options = { address:              'smtp.gmail.com',
                port:                 587,
                user_name:            'kristoole@gmail.com',
                password:             ENV['GMAIL_APP_KEY'],
                authentication:       'plain',
                enable_starttls_auto: true }

    puts "Mail: #{options}, #{ENV}"

    Mail.defaults do
      delivery_method :smtp, options
    end

    # Deliver to SMS (for now)
    Mail.deliver do
      to '6198883520@txt.att.net'
      from 'kristoole@gmail.com'
      subject subject
      body body
    end
  end
end
