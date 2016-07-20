require 'rails_helper'

RSpec.describe Prefix, type: :model do

  describe '#import_csv' do

    it 'treat the first line of the CSV file as a header' do
      str = <<-CSV
http://example0.com
http://example1.com
http://example2.com
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file, :element_type => "subject"}}
      Prefix.import_csv(params)
      expect(Prefix.where(uri: 'http://example0.com').count).to eq 0
      expect(Prefix.all.count).to eq 2
    end

    it 'saves no prefix when there is only header line in the CSV file' do
      str = <<-CSV
URI
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file, :element_type => "subject"}}
      Prefix.import_csv(params)
      expect(Prefix.where(uri: 'URI').count).to eq 0
      expect(Prefix.all.count).to eq 0
    end

    it 'saves no prefix when there is invalid URI in the CSV file' do
      str = <<-CSV
URI
http://example0.com
http://example1.com
file://
      CSV
      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file, :element_type => "subject"}}

      Prefix.import_csv(params)

      expect(Prefix.where(uri: 'file://').count).to eq 0
      expect(Prefix.all.count).to eq 0
    end

  end

end
