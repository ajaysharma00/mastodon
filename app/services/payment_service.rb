class PaymentService

  def self.create_stripe_customer(user, cart_info)
    if user.stripe_customer_id.present?
      customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      customer.source = get_token(cart_info).id
      customer.email = user.contact_email
      customer.save
    else
      customer = Stripe::Customer.create(source: get_token(cart_info),
      	                                 email: user.contact_email)
    end
    { success: true, customer_id: customer.id }
  rescue Exception => e
    { success: false, error: e.message }
  end

  def self.execute_stripe_subscription(membership)
    customer = Stripe::Customer.retrieve(membership.stripe_customer_id)
    customer.plan = membership.plan_id
    customer.save
    { success: true, customer_id: customer.id,
    	subscription_id: customer.subscriptions.first.id,
    	status: customer.subscriptions.first.status }
  rescue Exception => e
    { success: false, errors: e.message }
  end

  def self.update_stripe_subscription(card_info, plan_id=nil)
    begin
      customer = Stripe::Customer.retrieve(card_info.stripe_customer_id)
      subscription = customer.subscriptions.retrieve(card_info.subscription_id)
      subscription.plan = card_info.try(:plan_id) || plan_id
      subscription.save
      ['active', 'trialing'].include?(subscription.status) ? { success: true, status: subscription.status } : { success: false, error: "Failed to process subscription." }
    rescue Exception => e
      { success: false, error: e.message }
    end
  end

  private

  def self.get_token(cart_info)
    token = nil
    token = Stripe::Token.create(
    	card: { number: cart_info[:card_number],
              exp_month: cart_info[:exp_month],
              exp_year: cart_info[:exp_year],
              cvc: cart_info[:cvc] })
    token
  end
end