require 'rails_helper'

RSpec.describe Prefix, type: :model do

  describe '#import_csv' do

    it 'saves no prefix when there is only header line in the CSV file' do
      str = <<-CSV
URI,DENIED_URI,CASE_SENSITIVE
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}
      Prefix.import_csv(params)
      expect(Prefix.where(allow_regex: 'URI').count).to eq 0
      expect(Prefix.all.count).to eq 0
    end

    it 'raises exception and saves no prefix when there is invalid URI in the CSV file' do
      str = <<-CSV
URI,DENIED_URI,CASE_SENSITIVE
http://example0.com,http://denied_example0.com,false
http://example1.com,http://denied_example1.com,false
file://,,true
      CSV
      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}

      expect{ Prefix.import_csv(params) }.to raise_exception(Prefix::FormatError)
      expect(Prefix.all.count).to eq 0
    end

    it 'should raise exception if a value of case_sensitive column is not correct' do
      str = <<-CSV
URI,DENIED_URI,CASE_SENSITIVE
http://example1.com,http://denied_example1.com,invalid_as_boolean
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}
      expect{ Prefix.import_csv(params) }.to raise_exception(Prefix::FormatError)
      expect(Prefix.all.count).to eq 0
    end

    it 'parses csv whose denied_uri and case_sensitive are omitted' do
      str = <<-CSV
URI,DENIED_URI,CASE_SENSITIVE
http://example1.com
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}
      Prefix.import_csv(params)
      prefixes= Prefix.all.to_a
      expect(prefixes.count).to eq 1
      expect(prefixes[0].allow_regex).to eq 'http://example1.com'
      expect(prefixes[0].deny_regex).to eq('')
      expect(prefixes[0].case_sensitive).to eq(true)
    end

    it 'should create models from correct csv' do
      str = <<-CSV
URI,DENIED_URI,CASE_SENSITIVE
http://example1.com,http://denied_example1.com,false
http://example2.com,http://denied_example2.com,true
      CSV

      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}
      Prefix.import_csv(params)
      prefixes= Prefix.all.to_a
      expect(prefixes.count).to eq 2
      expect(prefixes[0].allow_regex).to eq 'http://example1.com'
      expect(prefixes[0].deny_regex).to eq 'http://denied_example1.com'
      expect(prefixes[0].case_sensitive).to eq(false)

      expect(prefixes[1].allow_regex).to eq 'http://example2.com'
      expect(prefixes[1].deny_regex).to eq 'http://denied_example2.com'
      expect(prefixes[1].case_sensitive).to eq(true)
    end

    it 'can be parse csv whose columns are reordered' do
      str = <<-CSV
URI,CASE_SENSITIVE,DENIED_URI
http://example1.com,false,http://denied_example1.com
http://example2.com,true,http://denied_example2.com
      CSV
      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}

      Prefix.import_csv(params)
      prefixes= Prefix.all.to_a
      expect(prefixes.count).to eq 2
      expect(prefixes[0].allow_regex).to eq 'http://example1.com'
      expect(prefixes[0].deny_regex).to eq 'http://denied_example1.com'
      expect(prefixes[0].case_sensitive).to eq(false)

      expect(prefixes[1].allow_regex).to eq 'http://example2.com'
      expect(prefixes[1].deny_regex).to eq 'http://denied_example2.com'
      expect(prefixes[1].case_sensitive).to eq(true)
    end

    it 'can be parse csv with redundant column ignoring them' do
      str = <<-CSV
URI,CASE_SENSITIVE,REDUNDANT,DENIED_URI
http://example1.com,false,redundant,http://denied_example1.com
http://example2.com,true,redundant,http://denied_example2.com
      CSV
      file = double(File)
      allow(file).to receive(:read).and_return(str)
      params = {:id => 1, :endpoint => {:file => file}}

      Prefix.import_csv(params)
      prefixes= Prefix.all.to_a
      expect(prefixes.count).to eq 2
      expect(prefixes[0].allow_regex).to eq 'http://example1.com'
      expect(prefixes[0].deny_regex).to eq 'http://denied_example1.com'
      expect(prefixes[0].case_sensitive).to eq(false)

      expect(prefixes[1].allow_regex).to eq 'http://example2.com'
      expect(prefixes[1].deny_regex).to eq 'http://denied_example2.com'
      expect(prefixes[1].case_sensitive).to eq(true)
    end
  end
end
