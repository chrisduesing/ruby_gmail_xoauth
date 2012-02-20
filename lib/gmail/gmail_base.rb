require 'net/imap'

module GmailBase
  VERSION = '0.0.9'

  class NoLabel < RuntimeError; end

  ###########################
  #  READING EMAILS
  #
  #  gmail.inbox
  #  gmail.label('News')
  #
  ###########################

  def inbox
    in_label('inbox')
  end

  def create_label(name)
    imap.create(name)
  end

  # List the available labels
  def labels
    (imap.list("", "%") + imap.list("[Gmail]/", "%")).inject([]) { |labels,label|
      label[:name].each_line { |l| labels << l }; labels }
  end

  # gmail.label(name)
  def label(name)
    mailboxes[name] ||= Mailbox.new(self, name)
  end
  alias :mailbox :label

  # don't mark emails as read on the server when downloading them
  attr_accessor :peek

  ###########################
  #  MAKING EMAILS
  # 
  #  gmail.generate_message do
  #    ...inside Mail context...
  #  end
  # 
  #  gmail.deliver do ... end
  # 
  #  mail = Mail.new...
  #  gmail.deliver!(mail)
  ###########################
  def generate_message(&block)
    require 'net/smtp'
    require 'smtp_tls'
    require 'mail'
    mail = Mail.new(&block)
    mail.delivery_method(*smtp_settings)
    mail
  end

  def deliver(mail=nil, &block)
    require 'net/smtp'
    require 'smtp_tls'
    require 'mail'
    mail = Mail.new(&block) if block_given?
    mail.delivery_method(*smtp_settings)
    mail.from = meta.username unless mail.from
    mail.deliver!
  end

  ###########################
  #  LOGIN
  ###########################

  # login method must be implemented by class, and set @logged_in to true on success

  def logged_in?
    !!@logged_in
  end
  # Log out of gmail
  def logout
    if logged_in?
      res = @imap.logout
      @logged_in = false if res && res.name == 'OK'
    end
  end
  
  # Shutdown socket and disconnect
  def disconnect
    logout if logged_in?
    @imap.disconnect unless @imap.disconnected?
  end  

  def in_mailbox(mailbox, &block)
    if block_given?
      mailbox_stack << mailbox
      unless @selected == mailbox.name
        imap.select(mailbox.name)
        @selected = mailbox.name
        @message_count = 1
      end
      value = block.arity == 1 ? block.call(mailbox) : block.call
      mailbox_stack.pop
      # Select previously selected mailbox if there is one
      if mailbox_stack.last
        imap.select(mailbox_stack.last.name)
        imap.add_response_handler do |resp|
          puts "Mailbox now has #{resp.data} messages"          
        end
        @selected = mailbox.name
      end
      return value
    else
      mailboxes[mailbox] ||= Mailbox.new(self, mailbox)
    end
  end
  alias :in_label :in_mailbox

  attr_accessor :message_count

  ###########################
  #  Other...
  ###########################
  def inspect
    "#<Gmail:#{'0x%x' % (object_id << 1)} (#{meta.username}) #{'dis' if !logged_in?}connected>"
  end
  
  # Accessor for @imap, but ensures that it's logged in first.
  def imap
    unless logged_in?
      login
      at_exit { logout } # Set up auto-logout for later.
    end
    @imap
  end

  private
    def mailboxes
      @mailboxes ||= {}
    end
    def mailbox_stack
      @mailbox_stack ||= []
    end
    def meta
      class << self; self end
    end
    def domain
      meta.username.split('@')[0]
    end
    
  # def smtp_settings must be defined by class, and return a list
      
    
end

require 'gmail/mailbox'
require 'gmail/message'

