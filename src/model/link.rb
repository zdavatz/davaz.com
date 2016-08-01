module DaVaz::Model
  class Link
    attr_accessor :link_id, :word, :artobject_id
    attr_reader :artobjects

    def initialize
      @artobjects = []
    end
  end
end
