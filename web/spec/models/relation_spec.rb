require 'rails_helper'

RSpec.describe Relation, type: :model do

  describe '#import_csv' do

    it 'ignores CSV header' do
      file_path = 'spec/data/models/relation/no_header.csv'

      Relation.import_csv(file_path)

      expect(Relation.where(endpoint_id: 1).where(name: 'seeAlso').count).to eq 0
      expect(Relation.all.count).to eq 2
    end

    it 'skips no contents in CSV file' do
      file_path = 'spec/data/models/relation/no_contents.csv'

      Relation.import_csv(file_path)

      expect(Relation.all.count).to eq 0
    end

    it 'validates the presence of endpoint_id' do
      file_path = 'spec/data/models/relation/empty_endpoint_id.csv'

      expect{Relation.import_csv(file_path)}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'validates the numericality of endpoint_id' do
      file_path = 'spec/data/models/relation/not_numeric_endpoint_id.csv'

      expect{Relation.import_csv(file_path)}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'validates the presence of name' do
      file_path = 'spec/data/models/relation/empty_name.csv'

      expect{Relation.import_csv(file_path)}.to raise_error(ActiveRecord::RecordInvalid)
    end

  end
end
