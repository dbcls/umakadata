# frozen_string_literal: true

module TruncateBytes
  extend ActiveSupport::Concern

  def truncate_bytes(truncate_from, truncate_to, omission: "…")
    omission ||= ""

    case
    when truncate_from.bytesize <= truncate_to
      truncate_from.dup
    when omission.bytesize > truncate_to
      raise ArgumentError, "Omission #{omission.inspect} is #{omission.bytesize}, larger than the truncation length of #{truncate_to} bytes"
    when omission.bytesize == truncate_to
      omission.dup
    else
      truncate_from.class.new.tap do |cut|
        cut_at = truncate_to - omission.bytesize

        truncate_from.each_grapheme_cluster do |grapheme|
          if cut.bytesize + grapheme.bytesize <= cut_at
            cut << grapheme
          else
            break
          end
        end

        cut << omission
      end
    end
  end
end
