class CreateStripeSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_subscriptions do |t|
      t.string   :plan_id
      t.string   :account_name
      t.string   :contact_email
      t.string   :stripe_customer_id
      t.string   :subscription_id
      t.datetime :expiry_date
      t.string   :status
      t.references :user, index: true

      t.timestamps
    end
  end
end
