require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'ContentNegotiation' do

      describe '#check_content_negotiation' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::ContentNegotiation } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com')
        end

        it 'detect_ttl_support_if_response_is_ttl' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::TURTLE)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::TURTLE)
          expect(result).to eq(true)
        end

        it 'detect_not_ttl_support_if_response_is_not_ttl' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::RDFXML)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::TURTLE)
          expect(result).to eq(false)
        end

        it 'detect_rdfxml_support_if_response_is_rdfxml' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::RDFXML)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::RDFXML)
          expect(result).to eq(true)
        end

        it 'detect_not_rdfxml_support_if_response_is_rdfxml' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::TURTLE)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::RDFXML)
          expect(result).to eq(false)
        end

        it 'detect_html_support_if_response_is_html' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::HTML)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::HTML)
          expect(result).to eq(true)
        end

        it 'detect_not_html_support_if_response_is_turtle' do
          response = double(Net::HTTPResponse)
          allow(response).to receive(:content_type).and_return(Yummydata::DataFormat::TURTLE)
          allow(target).to receive(:http_get_recursive).and_return(response)
          allow(response).to receive(:is_a?).and_return(true)

          result = target.check_content_negotiation(@uri, Yummydata::DataFormat::HTML)
          expect(result).to eq(false)
        end

      end
    end
  end
end
