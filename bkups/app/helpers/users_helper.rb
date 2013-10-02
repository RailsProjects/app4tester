module UsersHelper

   #these two methods are copied from the sample app; the method is called in the views
  def wrap(content)
      unless content.nil?
      sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
      end 
  end

  private

    def wrap_long_string(text, max_width = 20)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end

    def create_customer(token, plan, code, newprice, event_type)  #plan is now a my_plan_id

        if !code.nil? && is_valid_sub_coupon(code) 
        
        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :plan => plan,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email,
          :coupon => code 
        )

        else
        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :plan => plan,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email
        )

        end 
 
        if !customer.nil?
          current_user.update_attributes(:customer_id => customer.id, :customer => true, :admin => true)
         # will have to change this to calculated adjusted ER's for when a customer canceled a previous subscription
         #except this is for new users, so probalby won't have to do this
          if Plan.find_by_my_plan_id(plan) #to prevent a nil problem 
            @er = Plan.find_by_my_plan_id(plan).events_number
            @unlimited = Plan.find_by_my_plan_id(plan).unlimited
          else 
            @er = 0 #just so @er not undefined - will probably need to change this if-else-end code to be more elegant
          end 
          
         
          if event_type == 'reception'
            #create subscription
            @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id, :my_plan_id => plan, :active => true, :plan_name => Plan.find_by_my_plan_id(plan).name)
            @sub.coupon = code
            @sub.events_remaining = @er
            @sub.unlimited = @unlimited
            @sub.save 

            #update customer with subscription_id
            current_user.update_attributes(:subscription_id => @sub.id)

           #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
              :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
              :sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
              :sub_actual_monthly_cost_in_cents => newprice, :sub_coupon_name => @sub.coupon) 
            @r.save

            #mail receipt
            UserMailer.sub_receipt(current_user, @r).deliver

          else # event_type is an edu event type

            @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id, :my_plan_id => plan, :active => true, :plan_name => Plan.find_by_my_plan_id(plan).name)
            @sub.coupon = code
            @sub.events_remaining = @er
            @sub.unlimited = @unlimited
            @sub.save 

            #update customer with subscription_id
            current_user.update_attributes(:subscription_id => @sub.id)

           #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
              :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
              :sub_events_number => @sub.events_remaining, :sub_reg_annual_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).annual_cost_cents,
              :sub_actual_annual_cost_in_cents => newprice, :sub_coupon_name => @sub.coupon) 
            @r.save

            #mail receipt
            UserMailer.sub_receipt_edu(current_user, @r).deliver

          end 


          flash[:success] = "Thank you for subscribing to the #{Plan.find_by_my_plan_id(plan).name.titleize} plan!  You can now create a name page, from which you can 1) request name recordings, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
        else
          flash.now[:error] = "Something went wrong, please try again."
          false 
        end
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false

         
         
    end 




    def temp_password(token)
       @user.password=token
       @user.password_confirmation= token
    end 


    def customer_has_master_list?
        current_user.customer == true && !current_user.adminevents.nil? && current_user.adminevents.any? {|s| s.master == true }  
    end


    def customer_has_active_subscription?
        !current_user.subscriptions.nil? && current_user.subscriptions.any? {|s| s.active == true }  
    end

    # for a before_filter
    def customer_has_no_active_subscription
     if customer_has_active_subscription?
      redirect_to current_user
      flash[:notice] = "You already have an active subscription to our service."
     end 
    end 

    def active_sub_with_events_left?
       customer_has_active_subscription? && (current_user.subscriptions.select {|s| s.active == true}.first.unlimited == true || current_user.subscriptions.select {|s| s.active == true}.first.events_remaining > 0) 
    end# note that for unlimited = true subs, the machine stops looking; if it kept looking, it would throw an error because > can't be called on nil, and events_remaining is nil for unlimited subs 

    def only_sub_pages_left?
      active_sub_with_events_left? && current_user.purchased_events <= 0
    end

    def only_purch_pages_left? 
          !active_sub_with_events_left? && current_user.purchased_events > 0
    end 

    def purch_and_sub_pages_left?
       active_sub_with_events_left? && current_user.purchased_events > 0
    end 

    def no_pages_left?
      !active_sub_with_events_left? && current_user.purchased_events <= 0
    end 
    # do I need to account for possible negative numbes for purchased_events?  will try to prevent decrementing below zero in the code
    # changed from == to <= just to make sure the wells don't disappear if have a subscription but somehow purchased events falls below zero

    def sub_pages_left
      current_user.subscriptions.select {|s| s.active == true}.first.events_remaining
    end 
    # shouldn't get nil object problem as long as I only call this in situations whre customer_has_active_subscription? = true
    # using first even though should be only one active subscription per user

    def has_trialed?
       current_user.subscriptions.any? {|s| !s.canceled_at.nil? && s.canceled_at > s.created_at + 13.days }
    end 

    def has_not_trialed?
      !has_trialed? 
    end 

    def is_valid_single_use_coupon(coupon)
        !coupon.blank? && Coupon.find_by_free_page_name(coupon) && Coupon.find_by_free_page_name(coupon).active == true && Coupon.find_by_free_page_name(coupon).name == "single_use"
    end 

    def redeem_single_use_coupon(coupon)
       if Coupon.find_by_free_page_name(coupon)
        c = Coupon.find_by_free_page_name(coupon)
        #c.active = false 
        c.free_page_user = current_user.id
        c.save
      end  
    end 

    def is_valid_free_coupon(coupon)
        !coupon.blank? && Coupon.find_by_free_page_name(coupon) && Coupon.find_by_free_page_name(coupon).active == true && Coupon.find_by_free_page_name(coupon).name == "free"
    end 


  def is_valid_sub_coupon(coupon)
      Coupon.find_by_free_page_name(coupon) && Coupon.find_by_free_page_name(coupon).active == true && Coupon.find_by_free_page_name(coupon).name == "sub_discount"
  end 

  def is_valid_free_sub(coupon)
     !coupon.blank? && Coupon.find_by_free_page_name(coupon) && Coupon.find_by_free_page_name(coupon).active == true && Coupon.find_by_free_page_name(coupon).name == "free_sub"
  end 

    def create_sub_customer_without_stripe(plan, code)
          current_user.update_attributes(:customer => true, :admin => true)
          if Plan.find_by_my_plan_id(plan) #to prevent a nil problem
            @er = Plan.find_by_my_plan_id(plan).events_number
          else 
            @er = 0 #just so @er not undefined - will probably need to change this if-else-end code to be more elegant
          end 

          #create subscription
          @sub = Subscription.new(:user_id => current_user.id, :email => current_user.email, :my_plan_id => plan, :active => true, :plan_name => Plan.find_by_my_plan_id(plan).name)
          @sub.coupon = code
          @sub.events_remaining = @er
          @sub.save 

          #update customer with subscription_id
          current_user.update_attributes(:subscription_id => @sub.id)

           #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email,
              :subscription_id => @sub.id, :sub_my_plan_id => @sub.my_plan_id, :sub_plan_name => @sub.plan_name,
              :sub_events_number => @sub.events_remaining, :sub_reg_monthly_cost_in_cents => Plan.find_by_my_plan_id(@sub.my_plan_id).monthly_cost_cents,
              :sub_actual_monthly_cost_in_cents => 0, :sub_coupon_name => @sub.coupon) 
            @r.save

    end 



    # for non-subscription/by-the-event-page purchases
    def create_customer_purchase(token, number, cost, coupon)

      @cost = cost 

      # was passing in coupon here too
    #if number.to_i < 6 
    #   @cost = number.to_i*35 
    #end 
    #if number.to_i > 5 && number.to_i < 11 
   #    @cost = number.to_i*30 
    #end 
   # if number.to_i > 10 
   #    @cost = number.to_i*25 
   # end 
#
   # if !coupon.blank?
   #   if is_valid_single_use_coupon(coupon)
    #    @cost = 0
    #  end  
    #end 

        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email
        )

        # charge the Customer instead of the card
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => customer.id,
            :description => "#{number} pages"
        )

        if !customer.nil?
          current_user.update_attributes(:customer_id => customer.id, :customer => true, :admin => true)
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save

          #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save

            #mail receipt
            UserMailer.purchase_receipt(current_user, @r, tier_one_price, tier_two_price, tier_three_price).deliver

          flash[:success] = "Thank you for your purchase!  You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
        else
          flash.now[:error] = "Something went wrong, please try again."
          false 
        end
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false

         
         
    end 


    def grad_create_customer_purchase(token, number, cost, coupon)

      @cost = cost 

      # was passing in coupon here too
    #if number.to_i < 6 
    #   @cost = number.to_i*35 
    #end 
    #if number.to_i > 5 && number.to_i < 11 
   #    @cost = number.to_i*30 
    #end 
   # if number.to_i > 10 
   #    @cost = number.to_i*25 
   # end 
#
   # if !coupon.blank?
   #   if is_valid_single_use_coupon(coupon)
    #    @cost = 0
    #  end  
    #end 

        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email
        )

        # charge the Customer instead of the card
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => customer.id,
            :description => "#{number} pages"
        )

        if !customer.nil?
          current_user.update_attributes(:customer_id => customer.id, :customer => true, :admin => true)
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save

          #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save

            #mail receipt
            UserMailer.grad_purchase_receipt(current_user, @r, @cost, one_grad_price).deliver

          flash[:success] = "Thank you for your purchase!  You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
        else
          flash.now[:error] = "Something went wrong, please try again."
          false 
        end
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false

         
         
    end 

    def create_grad_customer_without_stripe(coupon)
          current_user.update_attributes(:customer => true, :admin => true)
            #max_redemptions is now being used for number of pages an promo code gets you when not defaulting to 1, like for Cecilia's sale
            if !Coupon.find_by_free_page_name(coupon).max_redemptions.blank?
              @number = Coupon.find_by_free_page_name(coupon).max_redemptions
            else
              @number = 1
            end 
          current_user.purchased_events = @number
          current_user.save
    end 

    #---------------------------Wedding code---------------------------------------------------------------
    def wed_create_customer_purchase(token, number, cost, coupon)

      @cost = cost 

        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email
        )

        # charge the Customer instead of the card
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => customer.id,
            :description => "#{number} pages"
        )

        if !customer.nil?
          current_user.update_attributes(:customer_id => customer.id, :customer => true, :admin => true)
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save

          #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save

            #mail receipt
            UserMailer.wed_purchase_receipt(current_user, @r, @cost, one_wed_price).deliver

          flash[:success] = "Thank you for your purchase!  You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
        else
          flash.now[:error] = "Something went wrong, please try again."
          false 
        end
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash.now[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false

         
         
    end 

    def create_wed_customer_without_stripe
          current_user.update_attributes(:customer => true, :admin => true)
          current_user.purchased_events = 1
          current_user.save
    end 

    #------------------------------------------------------------------------------------------------------

    # for a customer changing their subscription (for stripereceiver_existing action)
    def update_card_and_subscription(token, plan) # plan is now a my_plan_id
      
      c = Stripe::Customer.retrieve(current_user.customer_id)  #have this in the enveloping controller action as well, because of the 'undefined variable c' error i was getting from the 4000000000000341 card test

      #updates customer with new card
      c.card = token
      c.save

      #updates subscription plan in stripe 
      c.update_subscription(:plan => plan, :prorate => true)

        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

   end 

# for the purchase_sub_new_card action (stripe customer w/o active sub buying a sub)
  def update_card_and_new_subscription(token, plan, code) # plan is now a my_plan_id
      #should be a customer_id b/c downstream from option in which user has an existing stripe customer id
      c = Stripe::Customer.retrieve(current_user.customer_id)
 

      #updates customer with new card
      c.card = token
      c.save

      if !code.nil? && is_valid_sub_coupon(code) 
               #create subscription for this customer in stripe (note that update_subscription creates a new subscription for this customer in this case)
              if has_not_trialed?
              c.update_subscription(:plan => plan, :coupon => code)
              else #this shouldn't happen b/c in an upstream controller, set code to nil if has_trialed
              c.update_subscription(:plan => plan, :trial_end => (Date.today + 1.day).to_time.to_i, :coupon => code)
              end 
      else
             #create subscription for this customer in stripe (note that update_subscription creates a new subscription for this customer in this case)
            if has_not_trialed?
            c.update_subscription(:plan => plan)
            else
            c.update_subscription(:plan => plan, :trial_end => (Date.today + 1.day).to_time.to_i)
            end 
      end 

       rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

  end  

def existing_customer_purchase_events_existing_card(number, cost, coupon)
     
  @cost = cost

    # if number.to_i < 6 
    #   @cost = number.to_i*35 
    # end 

    # if number.to_i > 5 && number.to_i < 11 
   #    @cost = number.to_i*30 
    # end 

    # if number.to_i > 10 
    #   @cost = number.to_i*25 
    # end

       c = Stripe::Customer.retrieve(current_user.customer_id)
     
        # charge the Customer instead of the card
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => c.id,
            :description => "#{number} pages"
        )

        
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save
         
           #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save

            #mail receipt
            UserMailer.purchase_receipt(current_user, @r, tier_one_price, tier_two_price, tier_three_price).deliver
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}.  Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

end 

def update_card_and_purchase(token, number, cost, coupon)

  @cost = cost
    # if number.to_i < 6 
    #   @cost = number.to_i*35 
    # end 

    # if number.to_i > 5 && number.to_i < 11 
   #    @cost = number.to_i*30 
   #  end 

   #  if number.to_i > 10 
   #    @cost = number.to_i*25 
   #  end

     #should be a customer_id b/c downstream from option in which user has an existing stripe customer id
      c = Stripe::Customer.retrieve(current_user.customer_id)
 
      #updates customer with new card
      c.card = token
      c.save

      #create new charge for these event pages
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => c.id,
            :description => "#{number} pages"
        )
     
        #update purchased_events in my database
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save

            #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => c.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save
 
            #mail receipt
            UserMailer.purchase_receipt(current_user, @r, tier_one_price, tier_two_price, tier_three_price).deliver

       rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

end 

def create_customer_and_purchase_existing_user(token, number, cost, coupon)# this is almost like create_customer_purchase, except have flash.nows in that helper

  @cost = cost

  # if number.to_i < 6 
   #    @cost = number.to_i*35 
  #  end 
   # if number.to_i > 5 && number.to_i < 11 
  #     @cost = number.to_i*30 
  #  end 
   # if number.to_i > 10 
   #    @cost = number.to_i*25 
  #  end 
        # create a Customer
        customer = Stripe::Customer.create(
          :card => token,
          :description => "#{current_user.first_name} #{current_user.last_name}",
          :email => current_user.email
        )

        # charge the Customer instead of the card
        Stripe::Charge.create(
            :amount => @cost.to_i*100, # in cents
            :currency => "usd",
            :customer => customer.id,
            :description => "#{number} pages"
        )

        if !customer.nil?
          current_user.update_attributes(:customer_id => customer.id, :customer => true, :admin => true)
          @eventtotal = current_user.purchased_events + number.to_i
          current_user.purchased_events = @eventtotal
          current_user.save

           #create receipt
            @r = Receipt.new(:user_id => current_user.id, :email => current_user.email, :customer_id => customer.id,
               :events_number => number, :en_actual_cost_in_cents => @cost.to_i*100, :en_coupon_name => coupon) 
            @r.save

            #mail receipt
            UserMailer.purchase_receipt(current_user, @r, tier_one_price, tier_two_price, tier_three_price).deliver

          flash[:success] = "Thank you for your purchase!  You can now create an event page, from which you can 1) invite attendees to record their names, 2) hear those recordings, and 3) invite other admins (who can request and hear recordings)."
        else
          flash[:error] = "Something went wrong, please try again."
          false 
        end
        
        rescue Stripe::InvalidRequestError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false
       
        rescue Stripe::CardError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false

         rescue Stripe::StripeError => e
         logger.error "Stripe error while creating customer: #{e.message}"
         flash[:error] = "There was a problem processing your credit card. #{e.message}. Please try again."
         false


end 

def plan_set_one
    1  #this returns the integer 1
end 
def plan_set_two
    2  #this returns the integer 1
end 
def plan_set_three
    3  #this returns the integer 1
end 
def plan_set_commencement
    10  
end 
def plan_set_students
    11
end 
def plan_set_all_inclusive
    12
end 

def one_wed_price
  99
end

def one_grad_price
  99
end 

def tier_one_price
   75
end  

def tier_two_price
  65
end 

def tier_three_price
  55
end 

def anchor_and_update_pos(po)

    @pos = Practiceobject.where(:email => po.email)
     if @pos.any? 
             @pos.each do |x|
               if x.user_id.blank?
                   x.user_id = current_user.id
                   if x.save
                   x.update_attributes(notes: current_user.notes, phonetic: current_user.phonetic)
                   else
                    return false
                  end   
               end 
             end    
          end 
        # now that other PO's are anchored to a user, recording path for them gets updated in saveupload (after recordstep2)
end 


def copy_to_master(po, event) #event for which this po just created
    c = event.customerkeys.first.user #get customer for this event
    @user = current_user 
    
    c.customerevents.each do |f|  # for each of customer's events
       if f.master == true && !(f == event) # if that event is a master list, and not the event for which a po was just created
         # try to give user a PO for this event
              # first check to see if an existing PO with this email for this event, and leave the other events/PO's alone; if floating  # PO's with this email for other events, will be caught by the sign-up level checks - user can just sign in then to anchor 
              # themselves to that PO/event
              if !f.practiceobjects.blank? && !f.practiceobjects.find_by_user_id(@user.id) && f.practiceobjects.find_by_email(@user.email)  #there is an already a PO with user's em for this event, floating (not with a user_id - in which case, wouldn't want to update that anchored PO)
                  @po = f.practiceobjects.find_by_email(@user.email)
                  @po.update_attributes(:user_id => @user.id, :phonetic => @user.phonetic, :notes => @user.notes) #this should validate b/c # user is new 
              else #no floating PO's associated with this email for this event (from an 'invite attendee' invitation), so give a new PO
                    @po = Practiceobject.create(:user_id => @user.id, :event_id => f.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name, :phonetic => @user.phonetic, :notes => @user.notes) #needed to add email to PO to make sure PO saves, b/c of PO validations
              end 
       end 
    end
end


def adminpracticeobject
    #add a PO for that event for that user(admin), for kicks and also so that we take care of the 'existing admin being invited as regular user for the same event' case (in which case the attempt to create a new PO will fail and it will say 'already registered for this event')
      if  !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(@user.email) #check if PO exists for this event and em (floating PO)
        #update floating PO for this event/em (anchor to new user)
        @po = @event.practiceobjects.find_by_email(@user.email)
        @po.update_attributes(:user_id => @user.id) #this should validate b/c # user is new 
              redirect_to @user, notice: "Welcome to NameCoach, and thanks for registering to admin this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
      else  #no PO exists for this event and em
        #create a PO for this event and user
        @po = Practiceobject.new(:user_id => @user.id, :event_id => @event.id, :email => @user.email, :first_name => @user.first_name, :last_name => @user.last_name) #needed to add email to PO to make sure PO saves, b/c of PO validations}
              if @po.save  #should be fine - since this is a new user, there can't be a PO for this event with his ID - true, but            #still problem if ADMIN ALSO INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T            #REGISTERED YET
                redirect_to @user, notice: "Welcome to NameCoach, and thanks for registering to admin this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
              else #already a PO for this user_id and event, but this shouldn't happen since it's a new user
                redirect_to @user, notice: "Thanks for registering as an admin for this event. However, something may have gone wrong - please contact your event admin for #{@event.title}."
              end 
      end 

      anchor_and_update_pos(@po)
end 

def adminvoicegem(u)
      if !@event.voicegems.find_by_email(u.email) #this email has no voicegem for this event
        @vg = Voicegem.new(event_id: @event.id, user_id: u.id, first_name: u.first_name, last_name: u.last_name, email: u.email) 
        @vg.save
      end

end


def addvoicegem(u)
      if !@event.voicegems.find_by_user_id(u.id) #this email has no voicegem for this event
        @vg = Voicegem.new(event_id: @event.id, user_id: u.id, first_name: u.first_name, last_name: u.last_name, email: u.email) 
        @vg.save
      end
end 

def addadminpracticeobject
    if  !@event.practiceobjects.nil? && @event.practiceobjects.find_by_user_id(user.id) #check to see if PO already exists for this event/user_id
                                 redirect_to user, notice: "Thank you for registering as an admin for the event, #{@event.title}. Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                                  # thanks for signing up as admin
    else #PO does not exist for this event/user_id
        if !@event.practiceobjects.nil? && @event.practiceobjects.find_by_email(user.email) #check to see if PO exists for this event/em (floating)
            #anchor floating PO, default to user attributes
            @event.practiceobjects.find_by_email(user.email).update_attributes(:user_id => user.id, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic)  #keeping any admin notes intact
             #this update can't fail on account of the user.id b/c already checked to see if there's a PO with this user_id and event
            redirect_to user, notice: "Thank you for registering as an admin for this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
           
        else #PO does not exist for this event/em
              #create new PO, with all default attributes
              @po = Practiceobject.new(:user_id => user.id, :event_id => @event.id, :email => user.email, :recording => user.recording, :notes => user.notes, :phonetic => user.phonetic, :first_name => user.first_name, :last_name => user.last_name) #needed to add email to PO to make sure PO saves, b/c of PO validations}
                if @po.save  #should save, b/c already checked for a Po with this event and user id, and checking for PO's with this user's email (floating PO) solves the problem of and ADMIN ALSO having INVITED AT THAT EMAIL ADDRESS, THEREBY CREATING A PO, AND USER HASN'T REGISTERED for this event yet YET
                  redirect_to user, notice: "Thanks for registering as an admin for this event, #{@event.title}.  Click on your event to invite people to record their names and practice recorded names. Also check out your own NameGuide to create or update it."
                else #already a PO for this user_id and event, but this shouldn't happen since already checked for above
                   redirect_to user, notice: "Thanks for registering. However, something may have gone wrong - please contact your event admin for #{@event.title}."
                end 

        end
    end 
end


def bigdaddyevent
  (User.find_by_email('bigdaddy@example.com') && @event.customerkeys.find_by_user_id(User.find_by_email('bigdaddy@example.com').id)) || (User.find_by_email('bigdaddy2@example.com') && @event.customerkeys.find_by_user_id(User.find_by_email('bigdaddy2@example.com').id)) ||  (User.find_by_email('bigdaddy@bigdaddywalkerproductions.com') && @event.customerkeys.find_by_user_id(User.find_by_email('bigdaddy@bigdaddywalkerproductions.com').id))
end

def user_is_bigdaddy
  @user.email == 'bigdaddy@example.com' || @user.email == 'bigdaddy2@example.com' || @user.email == 'bigdaddy@bigdaddywalkerproductions.com'
end

def bounce_free_account
  if current_user.customer_id.blank?
      redirect_to current_user, notice: "You currently have a free account.  Please contact NameCoach if you wish to change anything."
      return false 
  end 
end 


def iolani
 (User.find_by_email('gradcust40@example.com') && @event.adminkeys.find_by_user_id(User.find_by_email('gradcust40@example.com').id)) || (User.find_by_email('tfleming@iolani.org') && @event.adminkeys.find_by_user_id(User.find_by_email('tfleming@iolani.org').id)) 
end


def student_event_user?
  current_user.event_type == 'students' || current_user.event_type == 'graduation' || current_user.event_type == 
  'commencement' || current_user.event_type == 'all_inclusive'
end 

def wed_event_user?
  current_user.event_type == 'wedding' || current_user.event_type == 'reception'
end 



#not being used - was an attempt to stop FF from loading old mp3's in users/show
  def set_cache_buster
        headers["Pragma"] = "no-cache"
        headers["Cache-Control"] = "must-revalidate"   
        headers["Cache-Control"] = "no-cache"   
        headers["Cache-Control"] = "no-store"      
  end

def vgfilter
  unless signed_in? && current_user.email == 'shanbhagp@aol.com'
    redirect_to voicegems_info_path
  end 

end 

end
