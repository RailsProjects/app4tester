App4::Application.routes.draw do

  resources :emails

  resources :vg_userinvites

  resources :voicegems do
    member do
      get :vgtest
    end
   end 

  resources :receipts

  resources :coupons

  resources :plans

  get "password_resets/new"

  resources :password_resets

  resources :subscriptions 

  resources :admininvites

  resources :userinvites

  resources :practiceobjects do
    member do
      get :porecording #nested routes was unnecessary here.  I'm passing in the relevant po id through the host option in the javascript, directly to the posaveupload url
                        # that's incorrect - this is allowing me to set @po in within the porecording action, which then is used to pass into the javascript and posaveupload action.
    end
  end 

  resources :adminkeys

  resources :customerkeys

 # resources :events, :path => '/'
#resources :posts, :path => "/admin/posts"
 resources :events do
 member do
    get :locked
    get :directory
  end 
end 

  resources :users do
    member do
      get :account
      put :post_account
      get :test
      get :autotest
      post :hide
    end
  end



 root to: 'users#home'
  
  resources :sessions, only: [:create, :destroy]

  match '/signin',  to: 'users#home'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/users/new/:token', to: 'users#new'
  #match 'invitedsignup/:token', to: 'users#invitedsignup', via: :get 
  #need to figure out how to do this custome matching thing - keep getting error that ther is no route matching [get] /invitedusers

  #resources :customerkeys, only: [:create, :destroy, :index]

  #path to remind a registered user to record their name
  match '/reminder', to: 'userinvites#reminder'#, via: :post 
  match '/rerecord', to: 'userinvites#rerecord'#, via: :post 

  match '/adminsignup/:token', to: 'admininvites#adminsignup', as: '/adminsignup'
  match '/adminsignup', to: 'users#home'  #this is to get rid of the 'no route matches GET adminsignup' for hitting that page w/o an invite
  #need to figure out why this is happening.  What does 'as' do? And why don't we have the same problem with users/new? probably because that's a restful resource

  match '/adminusercreate', to: 'admininvites#adminusercreate', via: :post 

  match '/homepageusercreate', to: 'users#homepageusercreate', via: :post
  #added a leading slash here, after it was already working

  match '/console', to: 'users#console'
  #solely for my own use; restrict this when deployed

  match '/saverecording', to: 'users#saverecording', via: :post 

  match '/upload', to: 'users#upload', via: :post

  match '/saveupload', to: 'users#saveupload'

  match '/playtest', to: 'users#playtest'

  match '/addpo', to: 'sessions#addpo'

  match '/addadmin', to: 'sessions#addadmin'

 match '/posaveupload', to: 'practiceobjects#posaveupload' 

 match '/eventcodesignup', to: 'users#eventcodesignup'
 match '/eventcodesignupcreate', to: 'users#eventcodesignupcreate', via: :post 
 match 'eventcodesignup_step2', to: 'users#eventcodesignup_step2'

 # signing up a new user with an event code
 #match '/signup', to: 'users#signup'

 match '/addeventcodeuser', to: 'sessions#addeventcodeuser'

 match '/admincodesignup', to: 'users#admincodesignup'
 match '/admincodesignupcreate', to: 'users#admincodesignupcreate', via: :post 

 match '/addcodeadmin', to: 'sessions#addcodeadmin'

 match '/purchase_sub_existing', to: 'users#purchase_sub_existing'  #this used to be called stripetest
 match 'purchase_sub_existing_edu', to: 'users#purchase_sub_existing_edu'
 match 'purchase_sub_existing_edu_bridge', to: 'users#purchase_sub_existing_edu_bridge'

 match '/stripereceiver', to: 'users#stripereceiver' #, via: :post 

 match '/cancel', to: 'subscriptions#cancel'

 match '/unsubscribe', to: 'subscriptions#unsubscribe'

 match '/newcustomer', to: 'users#newcustomer'

 match '/newcustomercreate', to: 'users#newcustomercreate'

 match '/stripenewcustomer', to: 'users#stripenewcustomer'

 match '/unhide', to: 'practiceobjects#unhide'

 match '/removeadmin', to: 'adminkeys#removeadmin'

 match '/new_step2', to: 'users#new_step2'
 #note that we don't use the :token thing here, even though token passed in- this is different both from the users-new and adminsignup methods!
 
 match '/skip', to: 'users#skip'

 match '/changepassword', to: 'users#changepassword'

 match '/value', to: 'static#value'
 match '/works', to: 'static#works'

 match '/test', to: 'users#test'

 match '/flashissue', to: 'static#flashissue'

 match '/pricing', to: 'subscriptions#pricing'

 match '/stripenewcustomertesting', to: 'users#stripenewcustomertesting'

 match '/changesub', to: 'users#changesub'

 match '/changesub_edu', to: 'users#changesub_edu'

 match '/newcustomer_purchase', to: 'users#newcustomer_purchase'

 match '/newcustomercreate_purchase', to: 'users#newcustomercreate_purchase'

 match '/stripenewcustomer_purchase', to: 'users#stripenewcustomer_purchase'

 match '/changepur', to: 'users#changepur'

 match '/stripereceiver_purchase', to: 'users#stripereceiver_purchase'

 match '/change_subscription', to: 'subscriptions#change_subscription'

 match '/changesubscription_choose', to: 'subscriptions#changesubscription_choose'

 match  '/stripereceiver_existing', to: 'subscriptions#stripereceiver_existing'

 match '/existing_card_changesub', to: 'subscriptions#existing_card_changesub'
 
 match '/purchase_sub_existing_choose', to: 'users#purchase_sub_existing_choose'

 match '/changesub_existinguser', to: 'users#changesub_existinguser'

 match '/purchase_sub_existing_card', to: 'users#purchase_sub_existing_card'

 match '/purchase_sub_new_card', to: 'users#purchase_sub_new_card'

 match '/purchase_sub_not_stripe_customer', to: 'users#purchase_sub_not_stripe_customer'

 match '/existing_user_purchase', to: 'users#existing_user_purchase'

 match '/existing_user_purchase_select', to: 'users#existing_user_purchase_select'

 match '/existing_changepur', to: 'users#existing_changepur'

 match '/purchase_events_existing_card', to: 'users#purchase_events_existing_card'

 match '/purchase_events_new_card', to: 'users#purchase_events_new_card'

 match '/purchase_events_new_stripe_customer', to: 'users#purchase_events_new_stripe_customer'

 match '/plantest', to: 'static#plantest'

 match '/coupon_purchase', to: 'users#coupon_purchase'

 match '/existing_coupon_purchase', to: 'users#existing_coupon_purchase'

 match '/sub_coupon', to: 'users#sub_coupon'
 match '/sub_coupon_edu', to: 'users#sub_coupon_edu'

 match '/sub_coupon_existing_user', to: 'users#sub_coupon_existing_user'

 match '/terms', to: 'static#terms'

 match '/cartest', to: 'static#cartest'

match '/record/:event_code', to: 'events#record', as: '/record'
match '/record', to: 'users#home'  #this is to get rid of the 'no route matches GET adminsignup' for hitting that page w/o an invite
  #need to figure out why this is happening.  What does 'as' do? And why don't we have the same problem with users/new? probably because that's a restful resource

match '/event_link_create', to: 'events#event_link_create'

match '/record_step2', to: 'events#record_step2'

match '/event_code_add', to: 'events#event_code_add'

match '/event_link_create_step2', to: 'events#event_link_create_step2'

match '/vg_rerecord', to: 'vg_userinvites#vg_rerecord'

match '/vg_unhide', to: 'voicegems#vg_unhide'

match '/vg_admininvite', to: 'admininvites#vg_admininvite'

match '/vgrecord/:event_code', to: 'voicegems#vgrecord', as: '/vgrecord'
match '/vgrecord', to: 'users#home'
match '/vgrecord_step2', to: 'voicegems#vgrecord_step2'

match '/vg_event_link_create', to: 'voicegems#vg_event_link_create'

match '/vgsaveupload', to: 'voicegems#vgsaveupload'

match  '/vg_event_code_add', to: 'voicegems#vg_event_code_add'

match '/macbeath', to: 'users#macbeath'

match 'macbeathindex', to: 'users#macbeathindex'

match 'login', to: 'users#login'

match 'grad_new_customer_purchase', to: 'users#grad_new_customer_purchase'

match 'grad_new_customer_create_purchase', to: 'users#grad_new_customer_create_purchase'

match 'stripe_grad_new_customer_purchase', to: 'users#stripe_grad_new_customer_purchase'

match 'grad_coupon_purchase', to: 'users#grad_coupon_purchase' 

match 'grad_stripereceiver_purchase', to: 'users#grad_stripereceiver_purchase'

match 'wed_new_customer_purchase', to: 'users#wed_new_customer_purchase'

match 'wed_new_customer_create_purchase', to: 'users#wed_new_customer_create_purchase'

match 'stripe_wed_new_customer_purchase', to: 'users#stripe_wed_new_customer_purchase'

match 'wed_coupon_purchase', to: 'users#wed_coupon_purchase' 

match 'wed_stripereceiver_purchase', to: 'users#wed_stripereceiver_purchase'

match 'weddings', to: "static#weddings"
match 'receptions', to: "static#receptions"
match 'graduations', to: "static#commencements"
match 'commencements', to: "static#commencements"
match 'students', to: "static#students"
match 'students_extra', to: "static#students_extra"
match 'students_naspa', to: 'static#students_naspa'
match 'students_naesp', to: 'static#students_naesp'

match 'demo_event_page', to: 'events#demo_event_page'
match 'demo_wedding_page', to: 'events#demo_wedding_page'
match 'demo_directory', to: 'events#demo_directory'

match '/demo_record/:event_code', to: 'events#demo_record', as: '/demo_record'
match '/demo_record_wedding/:event_code', to: 'events#demo_record_wedding', as: '/demo_record_wedding'
match '/demo_record_directory/:event_code', to: 'events#demo_record_directory', as: '/demo_record_directory'
match '/demo_record_vg/:event_code', to: 'voicegems#demo_record_vg', as: 'demo_record_vg'

match '/demo_record_temp/:event_code', to: 'events#demo_record_temp', as: '/demo_record_temp'

match '/demo_recorder', to: 'users#demo_recorder'
match '/demo_recorder_vg', to: 'users#demo_recorder_vg'

match '/privacy', to: 'static#privacy'

match '/faq', to: 'static#faq'

match '/team', to: 'static#team'

match '/macfaq', to: 'static#macfaq'

match '/flashtest', to: 'static#flashtest'

match '/BioE', to: 'events#BioE'
match '/bioe', to: 'events#BioE'

match '/macbeathtestimonial', to: 'static#macbeathtestimonial'

match '/test5', to: 'users#test5'

match '/support_test', to: 'static#support_test'
match '/search_test', to: 'static#search_test'


match '/irecord', to: 'static#irecord'
match '/isave', to: 'static#isave'

match '/new_sublist', to: 'events#new_sublist'
#match '/migrate_pos', to: 'events#migrate_pos'

match '/master_set', to: 'events#master_set'
match '/master_set_input', to: 'events#master_set_input'
match '/default_grad', to: 'events#default_grad'
match '/migrate_entries', to: 'events#migrate_entries'

match '/flashdetect', to: 'static#flashdetect'

match '/precord', to: 'static#precord'

match 'setpassword', to: 'users#setpassword'

match 'voicegems_info', to: 'voicegems#voicegems_info'




#match '/show_master', to: 'events#show_master'

#match '/vgrecord_step2', to: 'voicegems#vgrecord_step2'
#apparently this route is not needed since I'm only rendering the vgrecord_step2 action

 #match '/events/assets/' => redirect('/assets')
# match '/events/assets/etc' => redirect('/assets/%{etc}')
#match "/stories/:name" => redirect("/posts/%{name}")
 #match '/events/assets/*etc' => redirect('/assets/%{etc}')  #GIVES partial path
 #match '/events/assets/aplayer/*etc' => redirect('/assets/aplayer/%{etc}')  # gives same old path now! wtf?
 #match '/events/assets/aplayer/:a' => redirect('/assets/aplayer/%{a}') #gives path to audiojs
# match '/events/assets/aplayer/:a.:b' => redirect('/assets/aplayer/%{a}')  #gives same old path
#match '/events/assets/aplayer/:a' => redirect('/assets/aplayer/%{a}'), :requirements => { :a => /.*/ } # this gives same old path!
#match '/events/assets/aplayer/:e.:d?:c.:b.:a' => redirect('/assets/aplayer/%{a}')  #same old path
#match '/events/assets/aplayer/:e.:d.:b.:a' => redirect('/assets/aplayer/%{a}') #same old path

#match '/events/assets/aplayer/*a' => redirect('/assets/aplayer/%{a}'), :requirements => { :a => /.*/ }
#match '/events/assets/aplayer/audiojs.swf?playerInstance=audiojs/*a' => redirect('/assets/aplayer/audiojs.swf?playerInstance=audiojs%{a}'), :constraints => { :a => /.*/ }
#match '/events/assets/aplayer/*a' => redirect('/assets/aplayer/%{a}'), :constraints => { :a => /.*/ }
#match "/events/assets" => redirect {|p, req| "/assets/#{req.subdomain}" }  #same old route
#match "/events/assets/:name" => redirect {|params| "/assets/#{params[:name]}" }  # same old route
#match '/events/assets/aplayer/*a' => redirect('/assets/aplayer/%{a}'), :constraints => { :a => /[^/]+/ } #gives an application error
#match '/events/assets/aplayer/:a.:b?:c.:d.:e' => redirect('/assets/aplayer/%{a}.%{b}?%{c}.%{d}.%{e}') #same old route
#match '/events/assets/aplayer/*a.*b?*c.*d.*e' => redirect('/assets/aplayer/%{a}.%{b}?%{c}.%{d}.%{e}') #same old route
#match '/events/assets/aplayer/:a' => redirect('/assets/aplayer/%{a}')
#match '/events/assets/aplayer/:a.:b.:c.:d.:e' => redirect('/assets/aplayer/%{a}%{b}%{c}%{d}%{e}')#same old route
#match '/events/assets/aplayer/*a.*b.*c.*d.*e' => redirect('/assets/aplayer/%{a}%{b}%{c}%{d}%{e}')
#match "/stories/:name" => redirect("/posts/%{name}")
# map.connect ':scale/:text.:format', :controller => 'barcode', :requirements => { :text => /.*/ }

#SEPARATORS = %w( / ; . , ? )
#savannah-5516.herokuapp.com/assets/aplayer/audiojs.swf?playerInstance=audiojs.instances[%27audiojs0%27]&datetime=1352004313978.8704
# aplayer/:e.:d?:c.:b.:a
#aplayer/:e.:d.:b.:a
 #match '/hide/:id', to: 'practiceobjects#destroy', via: :destroy

  #match ':controller(/:action(/:id))(.:format)' 
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
