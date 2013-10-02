# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130815111129) do

  create_table "admininvites", :force => true do |t|
    t.integer  "event_id"
    t.string   "token"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "recipient_email"
    t.integer  "admin_id"
    t.integer  "user_id"
  end

  add_index "admininvites", ["token"], :name => "index_admininvites_on_token"

  create_table "adminkeys", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "event_id"
  end

  add_index "adminkeys", ["event_id"], :name => "index_adminkeys_on_event_id"
  add_index "adminkeys", ["user_id", "event_id"], :name => "index_adminkeys_on_user_id_and_event_id", :unique => true
  add_index "adminkeys", ["user_id"], :name => "index_adminkeys_on_user_id"

  create_table "coupons", :force => true do |t|
    t.string   "name",               :default => "single_use"
    t.integer  "percent_off"
    t.integer  "max_redemptions"
    t.string   "duration"
    t.integer  "duration_in_months"
    t.datetime "redeem_by"
    t.integer  "times_redeemed"
    t.string   "free_page_name"
    t.integer  "free_page_user"
    t.boolean  "active",             :default => true
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.datetime "redeemed_on"
    t.integer  "cost"
  end

  create_table "customerkeys", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "customerkeys", ["event_id"], :name => "index_customerkeys_on_event_id"
  add_index "customerkeys", ["user_id", "event_id"], :name => "index_customerkeys_on_user_id_and_event_id", :unique => true
  add_index "customerkeys", ["user_id"], :name => "index_customerkeys_on_user_id"

  create_table "emails", :force => true do |t|
    t.string   "recipient_email"
    t.string   "from_email"
    t.text     "body"
    t.datetime "sent_at"
    t.string   "cc_email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "subject"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "date"
    t.string   "access_code"
    t.string   "event_code"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "purchase_type"
    t.string   "event_type"
    t.boolean  "master"
    t.text     "grad_array"
    t.string   "grad_date"
  end

  add_index "events", ["access_code"], :name => "index_events_on_access_code"
  add_index "events", ["event_code"], :name => "index_events_on_event_code"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.integer  "events_number"
    t.integer  "trial_period"
    t.integer  "monthly_cost_cents"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "my_plan_id"
    t.integer  "annual_cost_cents"
    t.boolean  "unlimited"
    t.string   "event_type"
  end

  create_table "practiceobjects", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "admin_notes"
    t.integer  "userinvite_id"
    t.integer  "admin_id"
    t.string   "token"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "recording"
    t.string   "phonetic"
    t.text     "notes"
    t.boolean  "hidden"
    t.string   "rec_file_name"
    t.string   "rec_content_type"
    t.integer  "rec_file_size"
    t.datetime "rec_updated_at"
    t.string   "vidrec"
  end

  add_index "practiceobjects", ["email"], :name => "index_practiceobjects_on_email"
  add_index "practiceobjects", ["event_id"], :name => "index_practiceobjects_on_event_id"
  add_index "practiceobjects", ["token"], :name => "index_practiceobjects_on_token"
  add_index "practiceobjects", ["user_id", "event_id"], :name => "index_practiceobjects_on_user_id_and_event_id", :unique => true
  add_index "practiceobjects", ["user_id"], :name => "index_practiceobjects_on_user_id"

  create_table "receipts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.integer  "sub_my_plan_id"
    t.string   "sub_plan_name"
    t.integer  "sub_events_number"
    t.integer  "sub_reg_monthly_cost_in_cents"
    t.integer  "sub_actual_monthly_cost_in_cents"
    t.string   "sub_coupon_name"
    t.integer  "events_number"
    t.integer  "en_regular_cost_in_cents"
    t.integer  "en_actual_cost_in_cents"
    t.string   "en_coupon_name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "email"
    t.string   "customer_id"
    t.integer  "sub_reg_annual_cost_in_cents"
    t.integer  "sub_actual_annual_cost_in_cents"
    t.boolean  "unlimited"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.datetime "canceled_at"
    t.boolean  "active"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.text     "explanation"
    t.string   "plan_id"
    t.string   "customer_id"
    t.integer  "events_remaining", :default => 0
    t.integer  "events_used",      :default => 0
    t.string   "coupon"
    t.integer  "my_plan_id"
    t.string   "plan_name"
    t.boolean  "unlimited"
  end

  create_table "userinvites", :force => true do |t|
    t.integer  "practiceobject_id"
    t.integer  "admin_id"
    t.string   "recipient_email"
    t.datetime "sent_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "invite_type"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.string   "email"
    t.string   "remember_token"
    t.string   "recording"
    t.string   "phonetic"
    t.text     "notes"
    t.boolean  "admin"
    t.boolean  "customer",               :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.float    "salt"
    t.string   "invite_token"
    t.integer  "subscription_id"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "company"
    t.string   "customer_id"
    t.integer  "purchased_events",       :default => 0
    t.text     "vg_notes"
    t.string   "vg_request"
    t.string   "event_type"
    t.string   "grad_date"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["password_reset_token"], :name => "index_users_on_password_reset_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "vg_userinvites", :force => true do |t|
    t.integer  "voicegem_id"
    t.integer  "admin_id"
    t.string   "recipient_email"
    t.datetime "sent_at"
    t.string   "invite_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "voicegems", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "admin_notes"
    t.integer  "vg_userinvite_id"
    t.integer  "admin_id"
    t.string   "token"
    t.string   "recording"
    t.string   "request"
    t.text     "notes"
    t.boolean  "hidden"
    t.integer  "length"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
