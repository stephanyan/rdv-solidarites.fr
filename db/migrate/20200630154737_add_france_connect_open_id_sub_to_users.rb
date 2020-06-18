class AddFranceConnectOpenIdSubToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :france_connect_openid_sub, :string
  end
end
