module CASino
  class LoginAudit < ActiveRecord::Base
    belongs_to :ticket_granting_ticket

    scope :active, -> { where('ticket_granting_ticket_id IS NOT NULL') }

    def agent
      unless user_agent.blank?
        @agent ||= UserAgent.parse(user_agent)
      end
    end

    def updated_at
      created_at
    end

    def ticket
      nil
    end
  end
end
