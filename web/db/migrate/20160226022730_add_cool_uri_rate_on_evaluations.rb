class AddCoolUriRateOnEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :cool_uri_rate, :integer
  end
end
