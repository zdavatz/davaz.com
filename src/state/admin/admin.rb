require 'sbsm/viralstate'
require 'state/_partial/art_object'
require 'state/communication/guestbook'
require 'state/communication/links'
require 'state/communication/news'
require 'state/public/articles'
require 'state/gallery/init'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/admin/init'
require 'state/admin/art_object'
require 'state/admin/ajax'

module DaVaz
  module State
    module Admin
      module Admin
        include SBSM::ViralState

        EVENT_MAP = {
          :art_object             => State::Admin::ArtObject,
          :new_art_object         => State::Admin::ArtObject,
          :ajax_add_element       => State::Admin::AjaxAddElement,
          :ajax_add_form          => State::Admin::AjaxAddForm,
          :ajax_all_tags          => State::Admin::AjaxAllTags,
          :ajax_all_tags_link     => State::Admin::AjaxAllTagsLink,
          :ajax_remove_element    => State::Admin::AjaxRemoveElement,
          :ajax_delete_element    => State::Admin::AjaxDeleteElement,
          :ajax_delete_guest      => State::Admin::AjaxDeleteGuest,
          :ajax_delete_image      => State::Admin::AjaxDeleteImage,
          :ajax_save_live_edit    => State::Admin::AjaxSaveLiveEdit,
          :ajax_save_gb_live_edit => State::Admin::AjaxSaveGbLiveEdit,
          :ajax_upload_image      => State::Admin::AjaxUploadImage,
          :ajax_upload_image_form => State::Admin::AjaxUploadImageForm,
          :ajax_movie_gallery     => State::Works::AjaxAdminMovieGallery,
          :design                 => State::Works::AdminDesign,
          :drawings               => State::Works::AdminDrawings,
          :movies                 => State::Works::AdminMovies,
          :paintings              => State::Works::AdminPaintings,
          :photos                 => State::Works::AdminPhotos,
          :schnitzenthesen        => State::Works::AdminSchnitzenthesen,
          :gallery                => State::Gallery::AdminGallery,
          :guestbook              => State::Communication::AdminGuestbook,
          :links                  => State::Communication::AdminLinks,
          :news                   => State::Communication::AdminNews,
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
          fragment = @session.user_input(:fragment)
          model << "##{fragment}" unless fragment.empty?
          model.gsub!(%r{new_art_object|ajax.*}, 'gallery')
          State::Redirect.new(@session, model)
        end
      end
    end
  end
end
