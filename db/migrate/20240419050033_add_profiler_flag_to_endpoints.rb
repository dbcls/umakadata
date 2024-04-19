class AddProfilerFlagToEndpoints < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :profiler, :boolean, default: true
  end
end
