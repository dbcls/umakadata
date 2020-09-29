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

ActiveRecord::Schema.define(version: 2020_09_29_080032) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.string "comment"
    t.binary "request"
    t.binary "response"
    t.float "elapsed_time"
    t.string "trace"
    t.string "warnings"
    t.binary "exceptions"
    t.bigint "measurement_id"
    t.index ["measurement_id"], name: "index_activities_on_measurement_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notification", default: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "crawls", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.boolean "skip"
    t.index ["finished_at"], name: "index_crawls_on_finished_at"
    t.index ["started_at"], name: "index_crawls_on_started_at"
  end

  create_table "dataset_relations", force: :cascade do |t|
    t.bigint "src_endpoint_id"
    t.bigint "dst_endpoint_id"
    t.string "relation"
    t.bigint "endpoint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dst_endpoint_id"], name: "index_dataset_relations_on_dst_endpoint_id"
    t.index ["endpoint_id"], name: "index_dataset_relations_on_endpoint_id"
    t.index ["src_endpoint_id"], name: "index_dataset_relations_on_src_endpoint_id"
  end

  create_table "endpoints", force: :cascade do |t|
    t.string "name", null: false
    t.string "endpoint_url", null: false
    t.string "description_url"
    t.boolean "enabled", default: true, null: false
    t.string "viewer_url"
    t.integer "issue_id"
    t.integer "label_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "timeout", default: 4.0
    t.index ["endpoint_url"], name: "index_endpoints_on_endpoint_url", unique: true
    t.index ["issue_id"], name: "index_endpoints_on_issue_id", unique: true
    t.index ["label_id"], name: "index_endpoints_on_label_id", unique: true
    t.index ["name"], name: "index_endpoints_on_name", unique: true
  end

  create_table "evaluations", force: :cascade do |t|
    t.string "publisher"
    t.string "license"
    t.string "language"
    t.boolean "service_keyword", default: false, null: false
    t.boolean "graph_keyword", default: false, null: false
    t.decimal "data_scale"
    t.integer "score", default: 0, null: false
    t.integer "rank", default: 0, null: false
    t.boolean "cors", default: false, null: false
    t.boolean "alive", default: false, null: false
    t.float "alive_rate", default: 0.0, null: false
    t.date "last_updated"
    t.boolean "service_description", default: false, null: false
    t.boolean "void", default: false, null: false
    t.float "metadata", default: 0.0, null: false
    t.float "ontology", default: 0.0, null: false
    t.string "links_to_other_datasets"
    t.bigint "data_entry"
    t.boolean "support_html_format", default: false, null: false
    t.boolean "support_rdfxml_format", default: false, null: false
    t.boolean "support_turtle_format", default: false, null: false
    t.float "cool_uri", default: 0.0, null: false
    t.boolean "http_uri", default: false, null: false
    t.boolean "provide_useful_information", default: false, null: false
    t.boolean "link_to_other_uri", default: false, null: false
    t.float "execution_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "endpoint_id"
    t.bigint "crawl_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.boolean "timeout"
    t.float "alive_score"
    t.index ["crawl_id"], name: "index_evaluations_on_crawl_id"
    t.index ["created_at"], name: "index_evaluations_on_created_at"
    t.index ["endpoint_id"], name: "index_evaluations_on_endpoint_id"
    t.index ["updated_at"], name: "index_evaluations_on_updated_at"
  end

  create_table "excluding_graphs", force: :cascade do |t|
    t.string "uri"
    t.bigint "endpoint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint_id"], name: "index_excluding_graphs_on_endpoint_id"
  end

  create_table "measurements", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.string "comment"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.binary "exceptions"
    t.bigint "evaluation_id"
    t.index ["evaluation_id"], name: "index_measurements_on_evaluation_id"
  end

  create_table "resource_uris", force: :cascade do |t|
    t.string "uri"
    t.string "allow"
    t.string "deny"
    t.boolean "regex", default: false, null: false
    t.boolean "case_insensitive", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "endpoint_id"
    t.index ["endpoint_id"], name: "index_resource_uris_on_endpoint_id"
  end

  create_table "vocabulary_prefixes", force: :cascade do |t|
    t.string "uri", null: false
    t.bigint "endpoint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint_id"], name: "index_vocabulary_prefixes_on_endpoint_id"
    t.index ["uri"], name: "index_vocabulary_prefixes_on_uri"
  end

  add_foreign_key "activities", "measurements"
  add_foreign_key "dataset_relations", "endpoints"
  add_foreign_key "dataset_relations", "endpoints", column: "dst_endpoint_id"
  add_foreign_key "dataset_relations", "endpoints", column: "src_endpoint_id"
  add_foreign_key "evaluations", "crawls"
  add_foreign_key "evaluations", "endpoints"
  add_foreign_key "excluding_graphs", "endpoints"
  add_foreign_key "measurements", "evaluations"
  add_foreign_key "resource_uris", "endpoints"
  add_foreign_key "vocabulary_prefixes", "endpoints"
end
