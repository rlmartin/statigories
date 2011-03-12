class MailObserver
  def self.delivered_email(mail)
    recipient = mail.instance_variable_get(:@recipient)
    unless recipient == nil
      recipient.add_msg_sent_event(mail.to_s)
    else
      event_log = EventLog.create(:event_id => Event::EMAIL_MSG_SENT, :event_data => mail.to_s)
    end
  end
end
