require 'date'
require 'time'
class Object
  def to_imap_date
    Date.parse(to_s).strftime("%d-%B-%Y")
  end
end

module GmailBase
  class Mailbox
    attr_reader :name
    attr_accessor :uid_next

    def initialize(gmail, name)
      @gmail = gmail
      @name = name
      @uid_next = @gmail.imap.status(@name, ["UIDNEXT"])["UIDNEXT"]
      puts "#{uid_next}"
    end

    def inspect
      "<#Mailbox name=#{@name}>"
    end

    def to_s
      name
    end

    def search(key_or_opts = :all, opts={})
      puts "about to search"
      @gmail.imap.uid_search(build_query(key_or_opts, opts)).collect { |uid| messages[uid] ||= Message.new(@gmail, self, uid) }
    end

    def emails
      messages.values
    end

    # Method: emails
    # Args: [ :all | :unread | :read ]
    # Opts: {:since => Date.new}
    def build_query(key_or_opts = :all, opts={})
      if key_or_opts.is_a?(Hash) && opts.empty?
        query = ['ALL']
        opts = key_or_opts
      elsif key_or_opts.is_a?(Symbol) && opts.is_a?(Hash)
        aliases = {
          :all => ['ALL'],
          :unread => ['UNSEEN'],
          :read => ['SEEN']
        }
        query = aliases[key_or_opts]
      elsif key_or_opts.is_a?(Array) && opts.empty?
        query = key_or_opts
      else
        raise ArgumentError, "Couldn't make sense of arguments to #emails - should be an optional hash of options preceded by an optional read-status bit; OR simply an array of parameters to pass directly to the IMAP uid_query call."
      end
      if !opts.empty?
        # Support for several query macros
        # :before => Date, :on => Date, :since => Date, :from => String, :to => String
        query.concat ['SINCE', opts[:after].to_imap_date] if opts[:after]
        query.concat ['BEFORE', opts[:before].to_imap_date] if opts[:before]
        query.concat ['ON', opts[:on].to_imap_date] if opts[:on]
        query.concat ['FROM', opts[:from]] if opts[:from]
        query.concat ['TO', opts[:to]] if opts[:to]
      end

      # puts "Gathering #{(aliases[key] || key).inspect} messages for mailbox '#{name}'..."
      @gmail.in_mailbox(self) do
        puts "query: #{query}"
        return query
      end
    end

    # This is a convenience method that really probably shouldn't need to exist, but it does make code more readable
    # if seriously all you want is the count of messages.
    def count(*args)
      emails(*args).length
    end

    def messages
      @messages ||= {}
    end


    def prefetch
      @gmail.imap.examine(name)
      @gmail.imap.fetch(1..@uid_next, ["UID", "ENVELOPE"]).each do |email|
        uid = email.attr['UID']
        envelope = email.attr["ENVELOPE"]
        messages[uid] = Message.new(@gmail, self, uid, envelope) 
        # puts "#{uid} : #{envelope.from[0].mailbox}@#{envelope.from[0].host}: \t#{envelope.subject}"
      end
    end

  end
end
