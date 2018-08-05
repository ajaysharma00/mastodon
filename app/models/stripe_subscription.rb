# == Schema Information
#
# Table name: stripe_subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  plan_id            :string
#  account_name       :string
#  contact_email      :string
#  stripe_customer_id :string
#  subscription_id    :string
#  expiry_date        :datetime
#  status             :string
#  user_id            :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class StripeSubscription < ApplicationRecord
  belongs_to :user
end
