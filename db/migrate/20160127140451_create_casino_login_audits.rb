class CreateCASinoLoginAudits < ActiveRecord::Migration
  def change
    create_table :casino_login_audits do |t|
      t.integer :user_id, null: false
      t.integer :ticket_granting_ticket_id
      t.string :user_agent
      t.string :user_ip
      t.datetime :created_at
    end
  end
end
