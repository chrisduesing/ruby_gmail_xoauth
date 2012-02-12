require 'net/imap'
require 'gmail/gmail_base'

class Gmail
  include GmailBase


  ##################################
  #  Gmail.new(username, password)
  ##################################
  def initialize(username, password)
    # This is to hide the username and password, not like it REALLY needs hiding, but ... you know.
    # Could be helpful when demoing the gem in irb, these bits won't show up that way.
    class << self
      class << self
        attr_accessor :username, :password
      end
    end
    meta.username = username =~ /@/ ? username : username + '@gmail.com'
    meta.password = password
    @imap = Net::IMAP.new('imap.gmail.com',993,true,nil,false)
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
    res = @imap.login(meta.username, meta.password)
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
