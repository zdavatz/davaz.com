require 'state/art_object'
require 'state/redirect'

module DAVAZ
  module State
    module Works
      class RackState < State::Works::Global
        ARTGROUP_ID = nil

        def init
          @model = OpenStruct.new
          serie_id = @session.user_input(:serie_id)
          series   = @session.app.load_series_by_artgroup(artgroup_id)
          @model.series = series
          if(serie_id.nil?)
            unless(series.empty?)
              serie_id = series.first.serie_id
            end
          end
          @model.serie_id = serie_id
          url = @session.lookandfeel.event_url(:gallery, :ajax_rack, [
            [:artgroup_id, artgroup_id],
            [:serie_id,    serie_id]
          ])
          @model.serie_items = {
            'artObjectIds' =>  [],
            'images'       =>  [],
            'titles'       =>  [],
            'dataUrl'      =>  url,
            'serieId'      =>  serie_id,
          }
          serie = @session.app.load_serie(serie_id)
          if serie
            serie_items = serie.artobjects
            serie_items.each { |item|
              if Util::ImageHelper.has_image?(item.artobject_id)
                image = Util::ImageHelper.image_url(item.artobject_id, 'show')
                @model.serie_items['artObjectIds'].push(item.artobject_id)
                @model.serie_items['images'].push(image)
                @model.serie_items['titles'].push(item.title)
              end
            }
          end
        end

        def artgroup_id
          self.class.const_get(:ARTGROUP_ID)
        end
      end

      class AjaxRackUploadImage < SBSM::State
        include Magick

        VIEW     = View::ImageDiv
        VOLATILE = true

        def init
          string_io = @session.user_input(:image_file)
          if string_io
            artobject_id = @session.user_input(:artobject_id)
            if artobject_id
              Util::ImageHelper.store_upload_image(
                string_io, artobject_id)
              @model = OpenStruct.new
              @model.artobject = @session.app.load_artobject(artobject_id)
            end
          end
        end
      end

      # @api admin
      class AdminRackState < State::Works::RackState
        include AdminArtObjectMethods

        def ajax_upload_image
          AjaxRackUploadImage.new(@session, @model)
        end

        def delete
          @session.app.delete_artobject(@session.user_input(:artgroup_id))
          model = self.request_path
          fragment = @session.user_input(:fragment)
          if fragment
            frag_arr = fragment.split("_")
            model << "##{frag_arr[0]}_#{frag_arr[1]}"
          end
          newstate = State::Redirect.new(@session, model)
        end

        # @return state [SBSM::State]
        def update
          artobject_id = @session.user_input(:artobject_id)
          @model.artobject = @session.app.load_artobject(artobject_id)
          keys = %i{
            title artgroup_id serie_id serie_position tool_id material_id date
            country_id tags_to_s location form_language price size text url
          }
          data = update_hash(keys, [])
          unless error?
            if artobject_id
              res = @session.app.update_artobject(artobject_id, data)
              model = rebuild_model(data[:serie_id])
              newstate = State::Redirect.new(@session, model)
            else
              # assumes as new
              insert_id = @session.app.insert_artobject(data)
              image_path = @model.artobject.tmp_image_path
              Util::ImageHelper.store_tmp_image(image_path, insert_id)
              self
            end
          else
            reasign_attributes(data)
            @session.app.update_artobject(artobject_id, data)
            build_selections
            # new state
            State::Redirect.new(@session, rebuild_model(data[:serie_id]))
          end
        end

        private

        def rebuild_model(serie_id)
          model = self.request_path
          fragment = @session.user_input(:fragment)
          if fragment
            fragment_arr = fragment.split('_')
            if serie_id && !fragment.empty? && serie_id == fragment_arr[1]
              model << "##{fragment}"
            else
              fragment_arr[1] = serie_id
              model << "##{fragment_arr.join('_')}"
            end
          end
          model
        end
      end
    end
  end
end
