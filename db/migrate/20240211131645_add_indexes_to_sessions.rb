class AddIndexesToSessions < ActiveRecord::Migration[7.0]
  def change
    add_index(:sessions, :user_id)
    add_index(:sessions, :refresh_token_jti)
  end
end
