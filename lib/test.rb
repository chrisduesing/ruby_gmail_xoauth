$LOAD_PATH << '.'
require 'gmail'

class Test

  def self.username
    ARGV[0]
  end

  def self.password
    ARGV[1]
  end

  def self.run
    Net::IMAP.debug = true
    imap = Net::IMAP.new('imap.gmail.com',993,true,nil,false)
    imap.login(username, password)
    start = Time.now
    imap.examine('INBOX')
    max = imap.status('INBOX', ["UIDNEXT"])["UIDNEXT"]
    min = (max * 0.4).to_i
     imap.fetch(min..max, "ENVELOPE").each do |email|
      envelope = email.attr["ENVELOPE"]
      puts "#{envelope.from[0].mailbox}@#{envelope.from[0].host}: \t#{envelope.subject}"
      #puts message_id
    end
    stop = Time.now
    puts stop - start
  end
  
  def self.run2
    # Net::IMAP.debug = true
    gmail = Gmail.new(username, password)
    
    start = Time.now

    gmail.inbox.prefetch
    gmail.inbox.emails.each do |email|
      puts email.subject
    end
    stop = Time.now
    puts stop - start
  end
end

if __FILE__ == $PROGRAM_NAME
  Test.run2
end
