class StripeSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def new
    @membership = current_user.stripe_subscriptions.new
  end

  def create
    if current_user.stripe_subscriptions.blank?
      @membership = current_user.stripe_subscriptions.new(permit_params)
      create_stripe_subscriptions
    else
      @membership = current_user.stripe_subscriptions.take
      @membership.update_attributes!(permit_params)
      create_stripe_subscriptions(true)
    end
  end

  private

  def permit_params
    params.require(:stripe_subscription).permit(:account_name, :contact_email, :plan_id)
  end

  def create_stripe_subscriptions(is_update = flase)
    begin
      customer = PaymentService.create_stripe_customer(@membership, params)
      unless customer[:success]
        flash[:error] = customer[:error]
        return redirect_to new_stripe_subscription_path(plan_name: @membership.plan_id)
      end
      @membership.stripe_customer_id = customer[:customer_id]
      @membership.save!
      if is_update
        subscription = PaymentService.execute_stripe_subscription(@membership)
      else
        subscription = PaymentService.update_stripe_subscription(@membership, @membership.plan_id)
      end
      unless subscription[:success]
        flash[:error] = subscription[:errors]
        return redirect_to new_stripe_subscription_path(plan_name: @membership.plan_id)
      end
      @membership.update_attributes!(subscription_id: subscription[:subscription_id],
                                     status: subscription[:status])
      flash[:success] = "Your plan has been created successfully."
      return redirect_to root_path
    rescue Exception => e
      flash[:error] = e.message
      redirect_to new_stripe_subscription_path(plan_name: @membership.plan_id)
    end
  end
end
