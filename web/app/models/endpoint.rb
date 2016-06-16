require 'rdf/turtle'
require 'rdf/ntriples'
require 'rdf/rdfxml'

class Endpoint < ActiveRecord::Base
  has_many :evaluations
  has_one :evaluation

  def self.rdf_graph
    endpoints = []
    all.each do |endpoint|
      hash = endpoint.attributes
      hash['evaluation'] = endpoint.evaluations[0].attributes.select {|key, value| /_log$/ !~ key }
      endpoints << hash
    end
    UmakaRDF.build(endpoints)
  end

  def self.to_jsonld
    self.rdf_graph.dump(:jsonld, prefixes: UmakaRDF.prefixes)
  end

  def self.to_rdfxml
    self.rdf_graph.dump(:rdfxml, prefixes: UmakaRDF.prefixes)
  end

  def self.to_ttl
    self.rdf_graph.dump(:ttl, prefixes: UmakaRDF.prefixes)
  end

  after_save do
    if self.issue_id.nil?
      issue = GithubHelper.create_issue(self.name)
      self.update_column(:issue_id, issue[:number]) unless issue.nil?
    else
      GithubHelper.edit_issue(self.issue_id, self.name)
    end
  end

  after_destroy do
    GithubHelper.close_issue(self.issue_id) unless self.issue_id.nil?
  end

end
