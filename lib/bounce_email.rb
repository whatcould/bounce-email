# encoding: UTF-8
require 'mail'

module BounceEmail
  TYPE_HARD_FAIL = 'Permanent Failure'
  TYPE_SOFT_FAIL = 'Persistent Transient Failure'
  TYPE_SUCCESS   = 'Success'

  #qmail
  # Status codes are defined in rfc3463, http://www.ietf.org/rfc/rfc3463.txt
  # For code formatting, see http://www.ietf.org/rfc/rfc3463.txt
  # Some Exchange servers format codes as "[...] #0.0.0>", see http://support.microsoft.com/kb/284204

  # I used quite much from http://www.phpclasses.org/browse/package/2691.html
  class Mail
    def self.read(filename)
      Mail.new( ::Mail.read(filename) )
    end

    def initialize(mail)
      @mail = mail.is_a?(String) ? ::Mail.new(mail) : mail
      begin
        if mail.bounced? #fall back to bounce handling in Mail gem
          @bounced = true
          @diagnostic_code = mail.diagnostic_code
          @error_status = mail.error_status
        end
      rescue
        @bounced = @diagnostic_code = @error_status = nil
      end
    end


    def bounced?
      @bounced ||= check_if_bounce(@mail)
    end
    alias_method :is_bounce?, :bounced? #to stay backwards compatible

    def diagnostic_code
      @diagnostic_code ||= get_reason_from_status_code(code)
    end
    alias_method :reason, :diagnostic_code #to stay backwards compatible

    def error_status
      @error_status ||= get_code(@mail)
    end
    alias_method :code, :error_status #to stay backwards compatible

=begin  #Streamline with Mail Gem methods - IMPLEMENT ME!
    def final_recipien?
    end

    def action
    end

    def retryable?
    end
=end

    def type
      @type ||= get_type_from_status_code(code)
    end

    def original_mail
      @original_mail ||= get_original_mail(@mail)
    end

    def method_missing(m, *args)
      @mail.send(m, *args)
    end

    private
    def get_code(mail)
      return '97' if mail.subject.match(/delayed/i)
      return '98' if mail.subject.encode('utf-8').match(/(unzulässiger|unerlaubter) anhang/i)
      return '99' if mail.subject.encode('utf-8').match(/auto.*reply|vacation|vocation|(out|away).*office|on holiday|abwesenheits|autorespond|Automatische|eingangsbestätigung/i)

      if mail.parts[1]
        match_parts = mail.parts[1].body.match(/(Status:.|550 |#)([245]\.[0-9]{1,3}\.[0-9]{1,3})/)
        code = match_parts[2] if match_parts
        return code if code
      end

      # Now try getting it from correct part of tmail
      code = get_status_from_text(mail.body)
      return code if code

      # OK getting desperate so try getting code from entire email
      code = get_status_from_text(mail.to_s)
      code || 'unknown'
    end

    def get_status_from_text(email)
      #=begin
      # This function is taken from PHP Bounce Handler class (http://www.phpclasses.org/browse/package/2691.html)
      # Author: Chris Fortune
      # Big thanks goes to him
      # I transled them to Ruby and added some my parts
      #=end
      return "5.1.1" if email.match(/no such (address|user)|Recipient address rejected|User unknown|does not like recipient|The recipient was unavailable to take delivery of the message|Sorry, no mailbox here by that name|invalid address|unknown user|unknown local part|user not found|invalid recipient|failed after I sent the message|did not reach the following recipient|nicht zugestellt werden/i)
      return "5.1.2" if email.match(/unrouteable mail domain|Esta casilla ha expirado por falta de uso|I couldn't find any host named/i)
      if email.match(/mailbox is full|Mailbox quota (usage|disk) exceeded|quota exceeded|Over quota|User mailbox exceeds allowed size|Message rejected\. Not enough storage space|user has exhausted allowed storage space|too many messages on the server|mailbox is over quota|mailbox exceeds allowed size/i) # AA added 4th or
        return "5.2.2" if email.match(/This is a permanent error/i) # AA added this
        return "4.2.2"
      end
      return "5.1.0" if email.match(/Address rejected/)
      return "4.1.2" if email.match(/I couldn't find any host by that name/)
      return "4.2.0" if email.match(/not yet been delivered/i)
      return "5.2.0" if email.match(/mailbox unavailable|No such mailbox/i)
      return "5.4.4" if email.match(/Unrouteable address/i)
      return "4.4.7" if email.match(/retry timeout exceeded/i)
      return "5.2.0" if email.match(/The account or domain may not exist, they may be blacklisted, or missing the proper dns entries./i)
      return "5.5.4" if email.match(/554 TRANSACTION FAILED/i)
      return "4.4.1" if email.match(/Status: 4.4.1|delivery temporarily suspended|wasn't able to establish an SMTP connection/i)
      return "5.5.0" if email.match(/550 OU\-002|Mail rejected by Windows Live Hotmail for policy reasons/i)
      return "5.1.2" if email.match(/PERM_FAILURE: DNS Error: Domain name not found/i)
      return "4.2.0" if email.match(/Delivery attempts will continue to be made for/i)
      return "5.5.4" if email.match(/554 delivery error:/i)
      return "5.1.1" if email.match(/550-5.1.1|This Gmail user does not exist/i)
      return "5.7.1" if email.match(/5.7.1 Your message.*?was blocked by ROTA DNSBL/i) # AA added
      return "5.3.2" if email.match(/Technical details of permanent failure|Too many bad recipients/i)  && (email.match(/The recipient server did not accept our requests to connect/i) || email.match(/Connection was dropped by remote host/i) || email.match(/Could not initiate SMTP conversation/i)) # AA added
      return "4.3.2" if email.match(/Technical details of temporary failure/i) && (email.match(/The recipient server did not accept our requests to connect/i) || email.match(/Connection was dropped by remote host/i) || email.match(/Could not initiate SMTP conversation/i)) # AA added
      return "5.0.0" if email.match(/Delivery to the following recipient failed permanently/i) # AA added
      return '5.2.3' if email.match(/account closed|account has been disabled or discontinued|mailbox not found|prohibited by administrator|access denied|account does not exist/i)
    end

    def get_reason_from_status_code(code)
      return 'unknown' if code.nil? or code == 'unknown'
      array = {}
      array['00'] =  "Other undefined status is the only undefined error code. It should be used for all errors for which only the class of the error is known."
      array['10'] =  "Something about the address specified in the message caused this DSN."
      array['11'] =  "The mailbox specified in the address does not exist.  For Internet mail names, this means the address portion to the left of the '@' sign is invalid.  This code is only useful for permanent failures."
      array['12'] =  "The destination system specified in the address does not exist or is incapable of accepting mail.  For Internet mail names, this means the address portion to the right of the @ is invalid for mail.  This codes is only useful for permanent failures."
      array['13'] =  "The destination address was syntactically invalid.  This can apply to any field in the address.  This code is only useful for permanent failures."
      array['14'] =  "The mailbox address as specified matches one or more recipients on the destination system.  This may result if a heuristic address mapping algorithm is used to map the specified address to a local mailbox name."
      array['15'] =  "This mailbox address as specified was valid.  This status code should be used for positive delivery reports."
      array['16'] =  "The mailbox address provided was at one time valid, but mail is no longer being accepted for that address.  This code is only useful for permanent failures."
      array['17'] =  "The sender's address was syntactically invalid.  This can apply to any field in the address."
      array['18'] =  "The sender's system specified in the address does not exist or is incapable of accepting return mail.  For domain names, this means the address portion to the right of the @ is invalid for mail. "
      array['20'] =  "The mailbox exists, but something about the destination mailbox has caused the sending of this DSN."
      array['21'] =  "The mailbox exists, but is not accepting messages.  This may be a permanent error if the mailbox will never be re-enabled or a transient error if the mailbox is only temporarily disabled."
      array['22'] =  "The mailbox is full because the user has exceeded a per-mailbox administrative quota or physical capacity.  The general semantics implies that the recipient can delete messages to make more space available.  This code should be used as a persistent transient failure."
      array['23'] =  "A per-mailbox administrative message length limit has been exceeded.  This status code should be used when the per-mailbox message length limit is less than the general system limit.  This code should be used as a permanent failure."
      array['24'] =  "The mailbox is a mailing list address and the mailing list was unable to be expanded.  This code may represent a permanent failure or a persistent transient failure. "
      array['30'] =  "The destination system exists and normally accepts mail, but something about the system has caused the generation of this DSN."
      array['31'] =  "Mail system storage has been exceeded.  The general semantics imply that the individual recipient may not be able to delete material to make room for additional messages.  This is useful only as a persistent transient error."
      array['32'] =  "The host on which the mailbox is resident is not accepting messages.  Examples of such conditions include an immanent shutdown, excessive load, or system maintenance.  This is useful for both permanent and permanent transient errors. "
      array['33'] =  "Selected features specified for the message are not supported by the destination system.  This can occur in gateways when features from one domain cannot be mapped onto the supported feature in another."
      array['34'] =  "The message is larger than per-message size limit.  This limit may either be for physical or administrative reasons. This is useful only as a permanent error."
      array['35'] =  "The system is not configured in a manner which will permit it to accept this message."
      array['40'] =  "Something went wrong with the networking, but it is not clear what the problem is, or the problem cannot be well expressed with any of the other provided detail codes."
      array['41'] =  "The outbound connection attempt was not answered, either because the remote system was busy, or otherwise unable to take a call.  This is useful only as a persistent transient error."
      array['42'] =  "The outbound connection was established, but was otherwise unable to complete the message transaction, either because of time-out, or inadequate connection quality. This is useful only as a persistent transient error."
      array['43'] =  "The network system was unable to forward the message, because a directory server was unavailable.  This is useful only as a persistent transient error. The inability to connect to an Internet DNS server is one example of the directory server failure error. "
      array['44'] =  "The mail system was unable to determine the next hop for the message because the necessary routing information was unavailable from the directory server. This is useful for both permanent and persistent transient errors.  A DNS lookup returning only an SOA (Start of Administration) record for a domain name is one example of the unable to route error."
      array['45'] =  "The mail system was unable to deliver the message because the mail system was congested. This is useful only as a persistent transient error."
      array['46'] =  "A routing loop caused the message to be forwarded too many times, either because of incorrect routing tables or a user forwarding loop. This is useful only as a persistent transient error."
      array['47'] =  "The message was considered too old by the rejecting system, either because it remained on that host too long or because the time-to-live value specified by the sender of the message was exceeded. If possible, the code for the actual problem found when delivery was attempted should be returned rather than this code.  This is useful only as a persistent transient error."
      array['50'] =  "Something was wrong with the protocol necessary to deliver the message to the next hop and the problem cannot be well expressed with any of the other provided detail codes."
      array['51'] =  "A mail transaction protocol command was issued which was either out of sequence or unsupported.  This is useful only as a permanent error."
      array['52'] =  "A mail transaction protocol command was issued which could not be interpreted, either because the syntax was wrong or the command is unrecognized. This is useful only as a permanent error."
      array['53'] =  "More recipients were specified for the message than could have been delivered by the protocol.  This error should normally result in the segmentation of the message into two, the remainder of the recipients to be delivered on a subsequent delivery attempt.  It is included in this list in the event that such segmentation is not possible."
      array['54'] =  "A valid mail transaction protocol command was issued with invalid arguments, either because the arguments were out of range or represented unrecognized features. This is useful only as a permanent error. "
      array['55'] =  "A protocol version mis-match existed which could not be automatically resolved by the communicating parties."
      array['60'] =  "Something about the content of a message caused it to be considered undeliverable and the problem cannot be well expressed with any of the other provided detail codes. "
      array['61'] =  "The media of the message is not supported by either the delivery protocol or the next system in the forwarding path. This is useful only as a permanent error."
      array['62'] =  "The content of the message must be converted before it can be delivered and such conversion is not permitted.  Such prohibitions may be the expression of the sender in the message itself or the policy of the sending host."
      array['63'] =  "The message content must be converted to be forwarded but such conversion is not possible or is not practical by a host in the forwarding path.  This condition may result when an ESMTP gateway supports 8bit transport but is not able to downgrade the message to 7 bit as required for the next hop."
      array['64'] =  "This is a warning sent to the sender when message delivery was successfully but when the delivery required a conversion in which some data was lost.  This may also be a permanant error if the sender has indicated that conversion with loss is prohibited for the message."
      array['65'] =  "A conversion was required but was unsuccessful.  This may be useful as a permanent or persistent temporary notification."
      array['70'] =  "Something related to security caused the message to be returned, and the problem cannot be well expressed with any of the other provided detail codes.  This status code may also be used when the condition cannot be further described because of security policies in force."
      array['71'] =  "The sender is not authorized to send to the destination. This can be the result of per-host or per-recipient filtering.  This memo does not discuss the merits of any such filtering, but provides a mechanism to report such. This is useful only as a permanent error."
      array['72'] =  "The sender is not authorized to send a message to the intended mailing list. This is useful only as a permanent error."
      array['73'] =  "A conversion from one secure messaging protocol to another was required for delivery and such conversion was not possible. This is useful only as a permanent error. "
      array['74'] =  "A message contained security features such as secure authentication which could not be supported on the delivery protocol. This is useful only as a permanent error."
      array['75'] =  "A transport system otherwise authorized to validate or decrypt a message in transport was unable to do so because necessary information such as key was not available or such information was invalid."
      array['76'] =  "A transport system otherwise authorized to validate or decrypt a message was unable to do so because the necessary algorithm was not supported. "
      array['77'] =  "A transport system otherwise authorized to validate a message was unable to do so because the message was corrupted or altered.  This may be useful as a permanent, transient persistent, or successful delivery code."
      #custom codes
      array['97'] =  "Delayed"
      array['98'] =  "Not allowed Attachment"
      array['99'] =  "Vacation auto-reply"
      code = code.gsub(/\./,'')[1..2]
      array[code] || "unknown"
    end

    def get_type_from_status_code(code)
      return TYPE_HARD_FAIL if code.nil? or code == 'unknown'
      pre_code = code[0].chr.to_i
      array = {}
      array[5] = TYPE_HARD_FAIL
      array[4] = TYPE_SOFT_FAIL
      array[2] = TYPE_SUCCESS
      return array[pre_code]
      "Error"
    end

    def check_if_bounce(mail)
      return true if mail.subject.match(/(returned|undelivered) mail|mail delivery( failed)?|(delivery )(status notification|failure)|failure notice|undeliver(able|ed)( mail)?|return(ing message|ed) to sender/i)
      return true if mail.subject.match(/auto.*reply|vacation|vocation|(out|away).*office|on holiday|abwesenheits|autorespond|Automatische|eingangsbestätigung/i)
      return true if mail['precedence'].to_s.match(/auto.*(reply|responder|antwort)/i)
      return true if mail.from.to_s.match(/^(MAILER-DAEMON|POSTMASTER)\@/i)
      false
    end

    def get_original_mail(mail) #worked alright for me, for sure this as to be extended
      parts = mail.body.split("--- Below this line is a copy of the message.\r\n\r\n")
      if parts.size > 1
        ::Mail.new(parts.last)
      elsif mail.parts
        ::Mail.new(mail.parts[2].body)
      end
    rescue => e
      nil
    end

  end
end