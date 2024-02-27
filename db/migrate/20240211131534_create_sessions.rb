class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table(:sessions, id: :uuid) do |t|
      t.uuid(:user_id, null: false)
      t.uuid(:refresh_token_jti, null: false)
      t.datetime(:refresh_token_exp, null: false)

      t.timestamps
    end
  end
end
