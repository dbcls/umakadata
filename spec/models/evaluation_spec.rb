require 'rails_helper'

include FactoryGirl::Syntax::Methods

#RSpec.describe Evaluation, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
#end

RSpec.describe Evaluation, type: :model do
  after do
    FactoryGirl.reload
  end

  it 'calculate alive rate by 1 evaluation is dead' do
    eval = Evaluation.new(:latest => true, :alive => false)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 0.0
  end

  it 'calculate alive rate by 1 evaluation is alive' do
    eval = Evaluation.new(:latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 100.0
  end

  it 'calculate alive rate by 2 evaluation that latest evaluation is dead and 1 old evaluation is alive' do
    endpoint_id = 1
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => true)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0
  end

  it 'calculate alive rate by 2 evaluation that latest evaluation is alive and 1 old evaluation is dead' do
    endpoint_id = 1
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => false)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is dead and 29 old evaluation is alive' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => true)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 96.6
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is alive and 29 old evaluation is dead' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => false)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 3.3
  end
  
end
