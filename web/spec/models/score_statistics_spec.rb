require 'rails_helper'

RSpec.describe ScoreStatistics do

  it 'return 0.0 both of average and median averages when evaluation does not exist in endpoints' do
    statistics = ScoreStatistics.new

    average = statistics.calc_average
    median = statistics.calc_median

    expect(average).to eq 0.0
    expect(median).to eq 0.0
  end

  it 'return average and median when calulated one evaluation' do
    statistics = ScoreStatistics.new
    statistics.add_score(56.0)

    average = statistics.calc_average
    median = statistics.calc_median

    expect(average).to eq 56.0
    expect(median).to eq 56.0
  end

  it 'return average when calulated two evaluation' do
    statistics = ScoreStatistics.new
    statistics.add_score(50.0)
    statistics.add_score(10.0)

    average = statistics.calc_average

    expect(average).to eq 30.0
  end

  it 'return median when calulated two evaluation' do
    statistics = ScoreStatistics.new
    statistics.add_score(50.0)
    statistics.add_score(10.0)

    median = statistics.calc_median

    expect(median).to eq 30.0
  end

  it 'return average when calulated three evaluation' do
    statistics = ScoreStatistics.new
    statistics.add_score(50.0)
    statistics.add_score(10.0)
    statistics.add_score(30.0)

    average = statistics.calc_average

    expect(average).to eq 30.0
  end

  it 'return median when calulated three evaluation' do
    statistics = ScoreStatistics.new
    statistics.add_score(50.0)
    statistics.add_score(10.0)
    statistics.add_score(30.0)

    median = statistics.calc_median

    expect(median).to eq 30.0
  end

end
