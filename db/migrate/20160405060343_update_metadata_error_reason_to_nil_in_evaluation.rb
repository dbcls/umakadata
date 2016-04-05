class UpdateMetadataErrorReasonToNilInEvaluation < ActiveRecord::Migration
  def up
    Evaluation.all.each do |evaluation|
      begin
        JSON.parse(evaluation.metadata_error_reason, {:symbolize_names => true})
      rescue
        evaluation.update_attribute(:metadata_error_reason, nil)
      end
    end
  end
end
