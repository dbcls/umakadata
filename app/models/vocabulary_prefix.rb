class VocabularyPrefix < ApplicationRecord
  belongs_to :endpoint

  class << self
    attr_accessor :caches
  end
end
