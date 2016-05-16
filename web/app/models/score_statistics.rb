class ScoreStatistics


  def initialize
    @scores = []
  end

  def add_score(score)
    @scores.push(score)
  end

  def calc_average
    if @scores.empty?
      return 0.0
    end
    return @scores.inject(0.0){|r,i| r+=i } / @scores.size
  end

  def calc_median
    if @scores.empty?
      return 0.0
    end
    count = @scores.size
    @scores = @scores.sort
    if count % 2 == 0
      return (@scores[(count / 2)] + @scores[(count / 2) - 1] ) / 2
    end
    return @scores[((count / 2) - 1) + (count / 2)]
  end

  private
    attr_accessor :scores

end
