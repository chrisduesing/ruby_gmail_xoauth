require 'net/imap'
require 'gmail/gmail_base'

class GmailXoauth
  include GmailBase

  

  ##################################
  #  Gmail.new(username, password)
  ##################################
  def initialize(email, token, token_secret, consumer_key, consumer_secret)
    @email, @token, @token_secret, @consumer_key, @consumer_secret = email, token, token_secret, consumer_key, consumer_secret
    @imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    if block_given?
      login # This is here intentionally. Normally, we get auto logged-in when first needed.
      yield self
      logout
    end
  end



  ###########################
  #  LOGIN
  ###########################
  def login
    res = @imap.authenticate('XOAUTH', @email,
                      :consumer_key => @consumer_key, 
                      :consumer_secret => @consumer_secret,
                      :token => @token, 
                      :token_secret => @token_secret
                      )
    @logged_in = true if res && res.name == 'OK'
  end



  ###########################
  #  Other...
  ###########################
  def smtp_settings
    [:smtp, {:address => "smtp.gmail.com",
       :port => 587,
       :domain => domain,
       :user_name => meta.username,
       :password => meta.password,
       :authentication => 'plain',
       :enable_starttls_auto => true}]
  end

end


require 'gmail/oauth_string'
require 'gmail/imap_xoauth_authenticator'
require 'gmail/smtp_xoauth_authenticator'
