# Ruby Gmail Xoauth

This project is the merging of Daniel Parker's [ruby-gmail](https://github.com/dcparker/ruby-gmail) with Nicolas Fouché's [gmail_xoauth](https://github.com/nfo/gmail_xoauth)

The end result is a streamlined API for accessing gmail via IMAP and SMTP, either through a username/password or [OAuth](http://code.google.com/apis/gmail/oauth) credentials.


## Description

A Rubyesque interface to Gmail, with all the tools you'll need. Search, read and send multipart emails; archive, mark as read/unread, delete emails; and manage labels.

## Features

* Search emails
* Read emails (handles attachments)
* Emails: Label, archive, delete, mark as read/unread/spam
* Create and delete labels
* Create and send multipart email messages in plaintext and/or html, with inline images and attachments
* Utilizes Gmail's IMAP & SMTP, MIME-type detection and parses and generates MIME properly.

## Problems:

* May not correctly read malformed MIME messages. This could possibly be corrected by having IMAP parse the MIME structure.
* Cannot grab the plain or html message without also grabbing attachments. It might be nice to lazy-[down]load attachments.

## Example Code:

### 1) Require gmail

    require 'gmail' or 'gmail_xoauth'
    
### 2) Start an authenticated gmail session

    #    If you pass a block, the session will be passed into the block,
    #    and the session will be logged out after the block is executed.
    gmail = Gmail.new(username, password)
    	  or
    gmail = GmailXoauth.new(email, token, token_secret, consumer_key, consumer_secret)
    # ...do things...
    gmail.logout

    Gmail.new(username, password) do |gmail|
      # ...do things...
    end
	or
    GmailXoauth.new(email, token, token_secret, consumer_key, consumer_secret) do |gmail|
      # ...do things...
    end

### 3) Count and gather emails!
    
    # Get counts for messages in the inbox
    gmail.inbox.count
    gmail.inbox.count(:unread)
    gmail.inbox.count(:read)

    # Count with some criteria
    gmail.inbox.count(:after => Date.parse("2010-02-20"), :before => Date.parse("2010-03-20"))
    gmail.inbox.count(:on => Date.parse("2010-04-15"))
    gmail.inbox.count(:from => "myfriend@gmail.com")
    gmail.inbox.count(:to => "directlytome@gmail.com")

    # Combine flags and options
    gmail.inbox.count(:unread, :from => "myboss@gmail.com")
    
    # Labels work the same way as inbox
    gmail.mailbox('Urgent').count
    
    # Getting messages works the same way as counting: optional flag, and optional arguments
    # Remember that every message in a conversation/thread will come as a separate message.
    gmail.inbox.emails(:unread, :before => Date.parse("2010-04-20"), :from => "myboss@gmail.com")

    # Get messages without marking them as read on the server.
    gmail.peek = true
    gmail.inbox.emails(:unread, :before => Date.parse("2010-04-20"), :from => "myboss@gmail.com")
    
### 4) Work with emails!

    # any news older than 4-20, mark as read and archive it...
    gmail.inbox.emails(:before => Date.parse("2010-04-20"), :from => "news@nbcnews.com").each do |email|
      email.mark(:read) # can also mark :unread or :spam
      email.archive!
    end

    # delete emails from X...
    gmail.inbox.emails(:from => "x-fiancé@gmail.com").each do |email|
      email.delete!
    end

    # Save all attachments in the "Faxes" label to a folder
    folder = "/where/ever"
    gmail.mailbox("Faxes").emails.each do |email|
      if !email.message.attachments.empty?
        email.message.save_attachments_to(folder)
      end
    end

    # Save just the first attachment from the newest unread email (assuming pdf)
    # For #save_to_file:
    #   + provide a path - save to attachment filename in path
    #   + provide a filename - save to file specified
    #   + provide no arguments - save to attachment filename in current directory
    email = gmail.inbox.emails(:unread).first
    email.attachments[0].save_to_file("/path/to/location")

    # Add a label to a message
    email.label("Faxes")

    # Or "move" the message to a label
    email.move_to("Faxes")

### 5) Create new emails!

Creating emails now uses the amazing [Mail](http://rubygems.org/gems/mail) rubygem. See its [documentation here](http://github.com/mikel/mail). Ruby-gmail will automatically configure your Mail emails to be sent via your Gmail account's SMTP, so they will be in your Gmail's "Sent" folder. Also, no need to specify the "From" email either, because ruby-gmail will set it for you.

    gmail.deliver do
      to "email@example.com"
      subject "Having fun in Puerto Rico!"
      text_part do
        body "Text of plaintext message."
      end
      html_part do
        body "<p>Text of <em>html</em> message.</p>"
      end
      add_file "/path/to/some_image.jpg"
    end
    # Or, generate the message first and send it later
    email = gmail.generate_message do
      to "email@example.com"
      subject "Having fun in Puerto Rico!"
      body "Spent the day on the road..."
    end
    email.deliver!
    # Or...
    gmail.deliver(email)


## OAuth 

OAuth support is for after a token and key have been obtained for a specific user. Since this is already handled well in the oauth and omniauth gems, it is easier to use those rather than reinvent that functionality for this gem. For eductational purposes here is a [simple example of integration with oauth](https://github.com/chrisduesing/gmail_oauth_imap/blob/master/app/controllers/users_controller.rb). You will of course need to replace the consumer token and secret with your own, but this will work out of the box. For your own app, there are two ways to get this working:

For testing, you can generate and validate your OAuth tokens thanks to the awesome [xoauth.py tool](http://code.google.com/p/google-mail-xoauth-tools/wiki/XoauthDotPyRunThrough).

    $ python xoauth.py --generate_oauth_token --user=myemail@gmail.com

For production use you will want to get a proper consumer token and secret. One can be done via Google Account's [Manage Domains](https://accounts.google.com/ManageDomains) feature. 

Note: The gem supports 3-legged OAuth, and 2-legged OAuth for Google Apps Business or Education account owners. 2-legged OAuth support was added by [Wojciech Kruszewski](https://github.com/wojciech).


## Requirements

* ruby
* net/smtp
* net/imap
* mail
* shared-mime-info rubygem (for MIME-detection when attaching files)
* oauth
* shoulda

## Install via Bundler

    gem 'ruby_gmail_xoauth', :git => 'git://github.com/chrisduesing/ruby_gmail_xoauth.git'

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. 


## License
MIT License - See LICENSE file for details.
