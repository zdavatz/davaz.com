require 'state/art_object'
require 'state/communication/guestbook'
require 'state/communication/links'
require 'state/communication/news'
require 'state/public/articles'
require 'state/gallery/gallery'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/admin/login'
require 'state/admin/admin_home'
require 'state/admin/ajax_states'
require 'sbsm/viralstate'

module DAVAZ
  module State
    module Admin
      module Admin
        include SBSM::ViralState

        EVENT_MAP = {
          :art_object             => State::AdminArtObject,
          :ajax_add_element       => State::AjaxAddElement,
          :ajax_add_form          => State::AjaxAddForm,
          :ajax_all_tags          => State::AjaxAllTags,
          :ajax_all_tags_link     => State::AjaxAllTagsLink,
          :ajax_delete_element    => State::Admin::AjaxDeleteElement,
          :ajax_delete_guest      => State::Admin::AjaxDeleteGuest,
          :ajax_delete_image      => State::Admin::AjaxDeleteImage,
          :ajax_movie_gallery     => State::Works::AjaxAdminMovieGallery,
          :ajax_remove_element    => State::AjaxRemoveElement,
          :ajax_save_live_edit    => State::Admin::AjaxSaveLiveEdit,
          :ajax_save_gb_live_edit => State::Admin::AjaxSaveGbLiveEdit,
          :ajax_upload_image      => State::Admin::AjaxUploadImage,
          :ajax_upload_image_form => State::Admin::AjaxUploadImageForm,
          :design                 => State::Works::AdminDesign,
          :drawings               => State::Works::AdminDrawings,
          :gallery                => State::Gallery::AdminGallery,
          :guestbook              => State::Communication::AdminGuestbook,
          :links                  => State::Communication::AdminLinks,
          :movies                 => State::Works::AdminMovies,
          :new_art_object         => State::AdminArtObject,
          :news                   => State::Communication::AdminNews,
          :paintings              => State::Works::AdminPaintings,
          :photos                 => State::Works::AdminPhotos,
          :schnitzenthesen        => State::Works::AdminSchnitzenthesen,
          :work                   => State::Personal::AdminWork,
          :life                   => State::Personal::AdminLife
        }

        def ajax_desk
          if @session.user_input(:artobject_id)
            State::Gallery::AjaxAdminDeskArtobject.new(@session, [])
          else
            State::Gallery::AjaxDesk.new(@session, [])
          end
        end

        def ajax_check_removal_status
          State::Admin::AjaxCheckRemovalStatus.new(@session, [])
        end

        def foot_navigation
          [
            :logout,
            [:gallery,       :new_art_object],
            [:communication, :guestbook],
            [:communication, :shop],
            :email_link,
            [:communication, :news],
            [:communication, :links],
            [:personal,      :home],
          ]
        end

        def switch_zone(zone)
          infect(super)
        end

        def logout
          model = @previous.request_path
          if fragment = @session.user_input(:fragment)
            model << "##{fragment}" unless fragment.empty?
          end
          model.gsub! %r{new_art_object|ajax.*}, 'gallery'
          State::Redirect.new(@session, model)
        end
      end
    end
  end
end
