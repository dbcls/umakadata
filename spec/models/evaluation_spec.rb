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

    expect(alive_rate).to eq 0.0 # 0 / 1
  end

  it 'calculate alive rate by 1 evaluation is alive' do
    eval = Evaluation.new(:latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 100.0 # 1 / 1
  end

  it 'calculate alive rate by 2 evaluation that latest evaluation is dead and 1 old evaluation is alive' do
    endpoint_id = 1
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => true)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0 # 1 / 2
  end

  it 'calculate alive rate by 2 evaluation that latest evaluation is alive and 1 old evaluation is dead' do
    endpoint_id = 1
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => false)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0 # 1 / 2
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is dead and 29 old evaluation is alive' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => true)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 96.7 # 29 / 30
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is alive and 29 old evaluation is dead' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => false)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true)
    
    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 3.3 # 1 / 30 
  end

  it 'calculate alive rate by 30 evaluation that last 15 evaluations are alive and the others are dead' do
    endpoint_id = 1
    create_list(:evaluation, 14, :endpoint_id => endpoint_id, :latest => false, :alive => true)
    create_list(:evaluation, 15, :endpoint_id => endpoint_id, :latest => false, :alive => false)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true)

    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0 # 15 / 30
  end

  it 'should return nil when evaluation dose not exist' do
    endpoint_id = 10000
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => nil)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq nil
  end

  it 'should return nil when the kind of last updated date are less than two' do
    endpoint_id = 10000
    three_days_ago = 3.days.ago(Time.zone.now)
    (1..3).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => three_days_ago)}
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => three_days_ago)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq nil
  end

  it 'should return nil when the kind of last updated date is less than two, including N/A' do
    endpoint_id = 10000
    three_days_ago = 3.days.ago(Time.zone.now)
    (1..3).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => three_days_ago)}
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => nil)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq nil
  end

  it 'should return 2.3333333333333335 when endpoints is 3 times updated for 7 days' do
    endpoint_id = 10000
    six_days_ago = 6.days.ago(Time.zone.now)
    four_days_ago = 4.days.ago(Time.zone.now)
    one_days_ago = 1.days.ago(Time.zone.now)
    (4..6).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => six_days_ago)}
    (2..3).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => four_days_ago)}
    create(:evaluation, :endpoint_id => endpoint_id, :last_updated => one_days_ago)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => one_days_ago)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq 2.3333333333333335 # 7/3
  end

  it 'should return 3.5 when endpoint is 2 times updated and 2 times dead for 7 days' do
    endpoint_id = 10000
    four_days_ago = 4.days.ago(Time.zone.now)
    (4..6).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => nil)}
    (2..3).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => four_days_ago)}
    create(:evaluation, :endpoint_id => endpoint_id, :last_updated => nil)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => Time.zone.now)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq 3.5
  end

end
