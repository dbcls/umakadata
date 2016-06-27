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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160627031323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "endpoints", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "issue_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.boolean  "latest"
    t.boolean  "alive"
    t.float    "alive_rate"
    t.text     "response_header"
    t.text     "service_description"
    t.text     "void_uri"
    t.text     "void_ttl"
    t.boolean  "subject_is_uri"
    t.boolean  "subject_is_http_uri"
    t.boolean  "uri_provides_info"
    t.boolean  "contains_links"
    t.integer  "score"
    t.integer  "rank"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "cool_uri_rate"
    t.boolean  "support_content_negotiation"
    t.boolean  "support_turtle_format"
    t.boolean  "support_xml_format"
    t.boolean  "support_html_format"
    t.float    "execution_time"
    t.float    "metadata_score"
    t.float    "ontology_score"
    t.float    "vocabulary_score"
    t.date     "last_updated"
    t.text     "last_updated_source"
    t.integer  "update_interval"
    t.integer  "number_of_statements",            limit: 8
    t.text     "alive_log"
    t.text     "service_description_log"
    t.text     "uri_subject_log"
    t.text     "subject_is_uri_log"
    t.text     "subject_is_http_uri_log"
    t.text     "uri_provides_info_log"
    t.text     "contains_links_log"
    t.text     "void_ttl_log"
    t.text     "execution_time_log"
    t.text     "support_content_negotiation_log"
    t.text     "metadata_log"
    t.text     "number_of_statements_log"
    t.text     "cool_uri_rate_log"
    t.text     "last_updated_log"
    t.text     "vocabulary_log"
    t.text     "ontology_log"
    t.text     "support_turtle_format_log"
    t.text     "support_xml_format_log"
    t.text     "support_html_format_log"
    t.text     "supported_language"
  end

  create_table "update_statuses", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.integer  "count",       limit: 8
    t.text     "first"
    t.text     "last"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

end
