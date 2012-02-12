# gmail_xoauth [![Dependency Status](https://gemnasium.com/nfo/gmail_xoauth.png)](https://gemnasium.com/nfo/gmail_xoauth)

Get access to [Gmail IMAP and STMP via OAuth](http://code.google.com/apis/gmail/oauth), using the standard Ruby Net libraries.

The gem supports 3-legged OAuth, and 2-legged OAuth for Google Apps Business or Education account owners.

Note: 2-legged OAuth support was added by [Wojciech Kruszewski](https://github.com/wojciech).

## Install

    $ gem install gmail_xoauth

## Usage

### Get your OAuth tokens

For testing, you can generate and validate your OAuth tokens thanks to the awesome [xoauth.py tool](http://code.google.com/p/google-mail-xoauth-tools/wiki/XoauthDotPyRunThrough).

    $ python xoauth.py --generate_oauth_token --user=myemail@gmail.com

Or if you want some webapp code, check the [gmail-oauth-sinatra](https://github.com/nfo/gmail-oauth-sinatra) project.

### IMAP

For your tests, Gmail allows to set 'anonymous' as the consumer key and secret.

    require 'gmail_xoauth'
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH', 'myemail@gmail.com',
      :consumer_key => 'anonymous',
      :consumer_secret => 'anonymous',
      :token => '4/nM2QAaunKUINb4RrXPC55F-mix_k',
      :token_secret => '41r18IyXjIvuyabS/NDyW6+m'
    )
    messages_count = imap.status('INBOX', ['MESSAGES'])['MESSAGES']
    puts "Seeing #{messages_count} messages in INBOX"

Note that the [Net::IMAP#login](http://www.ruby-doc.org/core/classes/Net/IMAP.html#M004191) method does not use support custom authenticators, so you have to use the [Net::IMAP#authenticate](http://www.ruby-doc.org/core/classes/Net/IMAP.html#M004190) method.

If you use 2-legged OAuth:

    require 'gmail_xoauth'
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH', 'myemail@mydomain.com',
      :two_legged => true,
      :consumer_key => 'a',
      :consumer_secret => 'b'
    )

### SMTP

For your tests, Gmail allows to set 'anonymous' as the consumer key and secret.

    require 'gmail_xoauth'
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls_auto
    secret = {
      :consumer_key => 'anonymous',
      :consumer_secret => 'anonymous',
      :token => '4/nM2QAaunKUINb4RrXPC55F-mix_k',
      :token_secret => '41r18IyXjIvuyabS/NDyW6+m'
    }
    smtp.start('gmail.com', 'myemail@gmail.com', secret, :xoauth)
    smtp.finish

Note that +Net::SMTP#enable_starttls_auto+ is not defined in Ruby 1.8.6.

If you use 2-legged OAuth:

    require 'gmail_xoauth'
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls_auto
    secret = {
    	:two_legged => true,
      :consumer_key => 'a',
      :consumer_secret => 'b'
    }
    smtp.start('gmail.com', 'myemail@mydomain.com', secret, :xoauth)
    smtp.finish


## Compatibility

Tested on Ruby MRI 1.8.6, 1.8.7, 1.9.1 and 1.9.2. Feel free to send me a message if you tested this code with other implementations of Ruby.

The only external dependency is the [oauth gem](http://rubygems.org/gems/oauth).

## History

* 0.3.1 2-legged OAuth support confirmed by [BobDohnal](https://github.com/BobDohnal)
* 0.3.0 Experimental 2-legged OAuth support
* 0.2.0 SMTP support
* 0.1.0 Initial release with IMAP support and 3-legged OAuth

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Contact me

http://about.me/nfo

## Copyright

Copyright (c) 2011 Silentale SAS. See LICENSE for details.
=======
# Notice
I am looking for for a new project owner for this project.  Please contact me if you are interested in maintaining this 
project or being added as a contributor.  

Sincerely,  
[Joshavne Potter](mailto:yourtech@gmail.com?subject=ruby-gmail%20gem%20support)

Plus:

# ruby-gmail

* Homepage: [http://dcparker.github.com/ruby-gmail/](http://dcparker.github.com/ruby-gmail/)
* Code: [http://github.com/dcparker/ruby-gmail](http://github.com/dcparker/ruby-gmail)
* Gem: [http://gemcutter.org/gems/ruby-gmail](http://gemcutter.org/gems/ruby-gmail)

## Author(s)

* Daniel Parker of BehindLogic.com

Extra thanks for specific feature contributions from:

  * [Justin Perkins](http://github.com/justinperkins)
  * [Mikkel Malmberg](http://github.com/mikker)
  * [Julien Blanchard](http://github.com/julienXX)
  * [Federico Galassi](http://github.com/fgalassi)

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

    require 'gmail'
    
### 2) Start an authenticated gmail session

    #    If you pass a block, the session will be passed into the block,
    #    and the session will be logged out after the block is executed.
    gmail = Gmail.new(username, password)
    # ...do things...
    gmail.logout

    Gmail.new(username, password) do |gmail|
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

## Requirements

* ruby
* net/smtp
* net/imap
* tmail
* shared-mime-info rubygem (for MIME-detection when attaching files)

## Install

    gem install ruby-gmail

## License

(The MIT License)

Copyright (c) 2009 BehindLogic

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

