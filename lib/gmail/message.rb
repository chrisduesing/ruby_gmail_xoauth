module GmailBase
  class Message

    def initialize(gmail, mailbox, uid, subject=nil)
      @gmail = gmail
      @mailbox = mailbox
      @uid = uid
      @subject = subject
    end

    def inspect
      "<#Message:#{object_id} mailbox=#{@mailbox.name}#{' uid='+@uid.to_s if @uid}#{' message_id='+@message_id.to_s if @message_id}>"
    end

    # Auto IMAP info
    def uid
      @uid ||= @gmail.imap.uid_search(['HEADER', 'Message-ID', message_id])[0]
    end

    # IMAP Operations
    def flag(flg)
      @gmail.in_mailbox(@mailbox) do
        @gmail.imap.uid_store(uid, "+FLAGS", [flg])
      end ? true : false
    end

    def unflag(flg)
      @gmail.in_mailbox(@mailbox) do
        @gmail.imap.uid_store(uid, "-FLAGS", [flg])
      end ? true : false
    end

    # Gmail Operations
    def mark(flag)
      case flag
      when :read
        flag(:Seen)
      when :unread
        unflag(:Seen)
      when :deleted
        flag(:Deleted)
      when :spam
        move_to('[Gmail]/Spam')
      end ? true : false
    end

    def delete!
      @mailbox.messages.delete(uid)
      flag(:Deleted)
    end

    def label(name)
      @gmail.in_mailbox(@mailbox) do
        begin
          @gmail.imap.uid_copy(uid, name)
        rescue Net::IMAP::NoResponseError
          raise Gmail::NoLabel, "No label `#{name}' exists!"
        end
      end
    end

    def label!(name)
      @gmail.in_mailbox(@mailbox) do
        begin
          @gmail.imap.uid_copy(uid, name)
        rescue Net::IMAP::NoResponseError
          # need to create the label first
          @gmail.create_label(name)
          retry
        end
      end
    end

    # We're not sure of any 'labels' except the 'mailbox' we're in at the moment.
    # Research whether we can find flags that tell which other labels this email is a part of.
    # def remove_label(name)
    # end

    def move_to(name)
      label(name) && delete!
    end

    def archive!
      move_to('[Gmail]/All Mail')
    end

    # a new message only has a uid, so when listing an inbox full of subjects we don't want to have to download the full headers/body.
    # this lightens traffic size and serves as a caching mechanism for subjects
    def subject
      if !@subject && !@message && !@message.subject
        require 'mail'
        request= '(body[header.fields (subject)])'
        _body = @gmail.in_mailbox(@mailbox) { @gmail.imap.fetch(@uid, request)[0].attr[request] }
        tmp = Mail.new(_body)
        @subject = tmp.subject
      elsif !@subject && @message && @message.subject
        @subject = @message.subject
      end
      @subject
    end

    private

    # Parsed MIME message object
    def message
      if !@message
        require 'mail'
        request,part = 'RFC822','RFC822'
        request,part = 'BODY.PEEK[]','BODY[]' if @gmail.peek
        _body = @gmail.in_mailbox(@mailbox) { @gmail.imap.uid_fetch(uid, request)[0].attr[part] }
        @message = Mail.new(_body)
      end
      @message
    end

    # Delegate all other methods to the Mail message
    def method_missing(*args, &block)
      if block_given?
        message.send(*args, &block)
      else
        message.send(*args)
      end
    end
  end
end
