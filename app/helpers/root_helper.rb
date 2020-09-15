module RootHelper
  def data_for_score_histogram(evaluations)
    data = Array.new(5, 0)

    if evaluations.present?
      evaluations.each do |x|
        next unless (1..5).cover?(x.rank)

        data[x.rank - 1] += 1
      end
    end

    ('A'..'E').zip(data.reverse).to_h.to_json
  end
end
