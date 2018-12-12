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

ActiveRecord::Schema.define(version: 20181212013321) do

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

  create_table "crawl_logs", force: :cascade do |t|
    t.datetime "started_at",  null: false
    t.datetime "finished_at"
  end

  create_table "endpoints", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "issue_id"
    t.string   "description_url"
    t.boolean  "disable_crawling", default: false, null: false
    t.integer  "label_id"
    t.string   "viewer_url"
  end

  add_index "endpoints", ["name"], name: "index_endpoints_on_name", unique: true, using: :btree
  add_index "endpoints", ["url"], name: "index_endpoints_on_url", unique: true, using: :btree

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
    t.date     "last_updated"
    t.text     "last_updated_source"
    t.integer  "update_interval"
    t.integer  "number_of_statements",            limit: 8
    t.text     "alive_log"
    t.text     "service_description_log"
    t.text     "uri_subject_log"
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
    t.text     "ontology_log"
    t.text     "support_turtle_format_log"
    t.text     "support_xml_format_log"
    t.text     "support_html_format_log"
    t.boolean  "support_graph_clause"
    t.string   "supported_language"
    t.text     "linksets"
    t.text     "license"
    t.text     "publisher"
    t.datetime "retrieved_at"
    t.integer  "crawl_log_id"
    t.boolean  "support_service_clause"
    t.text     "support_service_clause_log"
  end

  add_index "evaluations", ["crawl_log_id"], name: "index_evaluations_on_crawl_log_id", using: :btree
  add_index "evaluations", ["created_at"], name: "index_evaluations_on_created_at", using: :btree
  add_index "evaluations", ["endpoint_id"], name: "index_evaluations_on_endpoint_id", using: :btree
  add_index "evaluations", ["retrieved_at"], name: "index_evaluations_on_retrieved_at", using: :btree

  create_table "linked_open_vocabularies", force: :cascade do |t|
    t.text     "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prefix_filters", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.string   "uri"
    t.string   "element_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "prefixes", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.string   "allow"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "deny"
    t.boolean  "case_insensitive", default: false, null: false
    t.boolean  "as_regex",         default: false
    t.boolean  "use_fixed_uri",    default: false
    t.string   "fixed_uri"
  end

  create_table "rdf_prefixes", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.string   "uri"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "relations", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.integer  "dst_id"
    t.text     "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "src_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "update_statuses", force: :cascade do |t|
    t.integer  "endpoint_id"
    t.text     "first"
    t.text     "last"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
