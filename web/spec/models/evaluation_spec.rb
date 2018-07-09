require 'rails_helper'

include FactoryBot::Syntax::Methods

#RSpec.describe Evaluation, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
#end

RSpec.describe Evaluation, type: :model do
  after do
    FactoryBot.reload
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
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => true, :retrieved_at => 10.days.ago(Time.zone.now))
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false, :retrieved_at => Time.zone.now)

    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0 # 1 / 2
  end

  it 'calculate alive rate by 2 evaluation that latest evaluation is alive and 1 old evaluation is dead' do
    endpoint_id = 1
    create(:evaluation, :endpoint_id => endpoint_id, :latest => false, :alive => false, :retrieved_at => 10.days.ago(Time.zone.now))
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true, :retrieved_at => Time.zone.now)

    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 50.0 # 1 / 2
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is dead and 29 old evaluation is alive' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => true, :retrieved_at => 10.days.ago(Time.zone.now))
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => false, :retrieved_at => Time.zone.now)

    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 96.7 # 29 / 30
  end

  it 'calculate alive rate by 30 evaluation that latest evaluation is alive and 29 old evaluation is dead' do
    endpoint_id = 1
    create_list(:evaluation, 29, :endpoint_id => endpoint_id, :latest => false, :alive => false, :retrieved_at => 10.days.ago(Time.zone.now))
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true, :retrieved_at => Time.zone.now)

    alive_rate = Evaluation.calc_alive_rate(eval)

    expect(alive_rate).to eq 3.3 # 1 / 30
  end

  it 'calculate alive rate by 30 evaluation that last 15 evaluations are alive and the others are dead' do
    endpoint_id = 1
    create_list(:evaluation, 14, :endpoint_id => endpoint_id, :latest => false, :alive => true, :retrieved_at => 10.days.ago(Time.zone.now))
    create_list(:evaluation, 15, :endpoint_id => endpoint_id, :latest => false, :alive => false, :retrieved_at => 5.days.ago(Time.zone.now))
    eval = Evaluation.new(:endpoint_id => endpoint_id, :latest => true, :alive => true, :retrieved_at => Time.zone.now)

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

  it 'should return  when endpoint is 3 times updated for 4 years' do
    endpoint_id = 10000
    four_years_ago = 4.years.ago(Time.zone.now)
    one_years_ago = 1.years.ago(Time.zone.now)
    create(:evaluation, :endpoint_id => endpoint_id, :last_updated => four_years_ago)
    create(:evaluation, :endpoint_id => endpoint_id, :last_updated => one_years_ago)
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => Time.zone.now)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq 730.5 # count / 2 spans of intervals
  end

  it 'should return 2.3333333333333335 when endpoint is 4 times updated for 7 days' do
    endpoint_id = 10000
    (7..7).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => 7.days.ago(Time.zone.now))}
    (6..6).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => 6.days.ago(Time.zone.now))}
    (4..5).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => nil)}
    (2..3).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => 4.days.ago(Time.zone.now))}
    (1..1).each{create(:evaluation, :endpoint_id => endpoint_id, :last_updated => nil)}
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => Time.zone.now)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq 2.3333333333333335 # counts / 3 spans of intervals
  end

  it 'should return 1 when endpoint is everyday updated for 7 days' do
    endpoint_id = 10000
    (1..6).each{|i| create(:evaluation, :endpoint_id => endpoint_id, :last_updated => i.days.ago(Time.zone.now))}
    eval = Evaluation.new(:endpoint_id => endpoint_id, :last_updated => Time.zone.now)

    update_interval = Evaluation.calc_update_interval(eval)

    expect(update_interval).to eq 1 # counts / 6 spans of intervals
  end

  it 'adjust_range should return all of data if the number of data is less than required' do
    before = Range.new(3, 5).to_a
    target = 6
    after = Range.new(7, 9).to_a

    results = Evaluation.adjust_range(before, target, after, 10)

    expect(results.size).to eq 7
    expect(results[0]).to eq 3
    expect(results[6]).to eq 9
  end

  it 'adjust_range should return an array of requested size which includes all of after data if after is less than half of required' do
    before = Range.new(1, 9).to_a
    target = 10
    after = Range.new(11, 13).to_a

    results = Evaluation.adjust_range(before, target, after, 10)

    expect(results.size).to eq 10
    expect(results[0]).to eq 4
    expect(results[9]).to eq 13
  end

  it 'adjust_range should return an array of requested size which includes all of before data if before is less than half of required' do
    before = Range.new(8, 9).to_a
    target = 10
    after = Range.new(11, 20).to_a

    results = Evaluation.adjust_range(before, target, after, 10)

    expect(results.size).to eq 10
    expect(results[0]).to eq 8
    expect(results[9]).to eq 17
  end

  it 'adjust_range should return an array whose center is target value if before and after have enough size' do
    before = Range.new(1, 14).to_a
    target = 15
    after = Range.new(16, 30).to_a

    results = Evaluation.adjust_range(before, target, after, 10)

    expect(results.size).to eq 10
    expect(results[0]).to eq 11
    expect(results[4]).to eq 15
    expect(results[9]).to eq 20
  end

end
