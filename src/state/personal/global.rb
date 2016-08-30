require 'state/global'
require 'state/predefine'
require 'state/personal/init'
require 'state/personal/life'
require 'state/personal/work'
require 'state/personal/inspiration'
require 'state/personal/family'
require 'state/personal/thefamily'
require 'util/image_helper'

module DaVaz::State
  module Personal
    class Global < DaVaz::State::Global
      HOME_STATE = Init
      ZONE       = :personal
      EVENT_MAP  = {
        :home        => Init,
        :life        => Life,
        :work        => Work,
        :inspiration => Inspiration,
        :family      => Family,
        :the_family  => TheFamily
      }

      def add_show_items(ostruct, name)
        ostruct.show_items = {
          'images' => [],
          'titles' => []
        }
        artobjects = @session.app.load_tag_artobjects(name)
        artobjects.each { |artobject|
          image = DaVaz::Util::ImageHelper.image_url(
            artobject.artobject_id, 'slide')
          @model.show_items['images'].push(image)
          @model.show_items['titles'].push(artobject.title)
        }
        ostruct
      end
    end
  end
end
