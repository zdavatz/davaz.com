require 'sbsm/state'
require 'view/_partial/redirect'

module DaVaz::State
  class Redirect < SBSM::State
    VIEW = DaVaz::View::Redirect

    def switch_zone(zone)
      name  = zone.to_s.split('_').collect { |word| word.capitalize }.join
      klass = DaVaz::State.const_get(name).const_get('Global')
      newstate = klass.new(@session, @model)
      newstate.switched_zone = true
      newstate
    rescue NameError => e
      puts e.class, e.message
      @previous
    end
  end
end
