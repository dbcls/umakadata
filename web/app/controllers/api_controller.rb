require 'json'

class ApiController < ApplicationController

  def specifications
  end

  def endpoints_search
    @endpoints = SearchForm.new(request.query_parameters).search

    respond_to do |format|
      format.jsonld  { render json: @endpoints.to_jsonld }
      format.xml     { render xml:  @endpoints.to_xml }
      format.rdfxml  { render xml:  @endpoints.to_rdfxml }
      format.ttl     { render text: @endpoints.to_ttl }
      format.json    { render json: @endpoints.to_pretty_json }
      format.any     { render json: @endpoints.to_pretty_json }
    end
  end

  def endpoints_graph
    nodes = Endpoint.all.map do |endpoint|
      {
        :group => "nodes",
        :data => {
          :id => "n#{endpoint.id}",
          :name => endpoint.name
        }
      }
    end
    index = 0
    edges = Relation.joins(:endpoint).pluck(:src_id, :dst_id, :name).uniq.map {|element|
      {
        :group => "edges",
        :data => {
          :id => "e#{index += 1}",
          :source => "n#{element[0]}",
          :target => "n#{element[1]}",
          :label => element[2]
        }
      }
    }
    edges.reject!{|edge| edge[:data][:source] == edge[:data][:target]}
    render :json => nodes.concat(edges)
  end

  def evaluation_id
    evaluation_id = ""
    unless params['date'].nil?
      begin
        date = Time.zone.parse(params['date'])
        day_begin = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
        day_end = Time.zone.local(date.year, date.mon, date.day, 23, 59, 59)
        crawlLog = CrawlLog.where('started_at': [day_begin..day_end]).order(['started_at ASC']).first
        evaluation = Evaluation.where(:endpoint_id => params[:id], 'crawl_log_id' => crawlLog.id).first
        evaluation_id = evaluation.id unless evaluation.nil?
      rescue
      end
    end
    render :json => {:evaluation_id => evaluation_id}
  end
end
