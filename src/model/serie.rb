require 'model/art_object'

module DaVaz::Model
  class Serie
    attr_accessor :serie_id, :name
    attr_reader :artobjects
    alias sid serie_id

    def initialize
      @artobjects = []
    end
  end
end
