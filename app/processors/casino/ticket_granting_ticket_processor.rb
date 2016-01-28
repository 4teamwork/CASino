module CASino::TicketGrantingTicketProcessor
  extend ActiveSupport::Concern

  include CASino::BrowserProcessor

  def find_valid_ticket_granting_ticket(ticket, user_agent, options = {})
    tgt = CASino::TicketGrantingTicket.where(ticket: ticket).first
    unless tgt.nil?
      if tgt.expired?
        Rails.logger.info "Ticket-granting ticket expired (Created: #{tgt.created_at})"
        tgt.destroy
        nil
      elsif !options[:ignore_two_factor] && tgt.awaiting_two_factor_authentication?
        Rails.logger.info 'Ticket-granting ticket is valid, but two-factor authentication is pending'
        nil
      elsif same_browser?(tgt.user_agent, user_agent)
        tgt.user_agent = user_agent
        tgt.touch
        tgt.save!
        tgt
      else
        Rails.logger.info 'User-Agent changed: ticket-granting ticket not valid for this browser'
        nil
      end
    end
  end

  def acquire_ticket_granting_ticket(authentication_result, user_agent, user_ip, options = {})
    user_data = authentication_result[:user_data]
    user = load_or_initialize_user(authentication_result[:authenticator], user_data[:username], user_data[:extra_attributes])
    cleanup_expired_ticket_granting_tickets(user)
    ActiveRecord::Base.transaction do
      tgt = user.ticket_granting_tickets.create!({
        awaiting_two_factor_authentication: two_factor_authentication_required?(user, user_ip),
        user_agent: user_agent,
        user_ip: user_ip,
        long_term: !!options[:long_term]
       })
      user.login_audits.create!(user_agent: user_agent, user_ip: user_ip, ticket_granting_ticket: tgt)
      tgt
    end
  end

  def load_or_initialize_user(authenticator, username, extra_attributes)
    user = CASino::User
      .where(authenticator: authenticator, username: username)
      .first_or_initialize
    user.extra_attributes = extra_attributes
    user.save!
    return user
  end

  def remove_ticket_granting_ticket(ticket_granting_ticket, user_agent)
    tgt = find_valid_ticket_granting_ticket(ticket_granting_ticket, user_agent)
    tgt.destroy unless tgt.nil?
  end

  def cleanup_expired_ticket_granting_tickets(user)
    CASino::TicketGrantingTicket.cleanup(user)
  end

  private
  def two_factor_authentication_required?(user, user_ip)
    if (whitelist = CASino.config.two_factor_authenticator[:whitelist]).any?
      !CASino::IPWhitelist.new(whitelist).include?(user_ip)
    else
      !user.active_two_factor_authenticator.nil?
    end
  end
end
