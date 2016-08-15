require 'state/communication/guestbook'
require 'state/communication/links'
require 'state/communication/news'
require 'state/public/articles'
require 'state/gallery/init'
require 'state/gallery/result'
require 'state/personal/life'
require 'state/personal/work'
require 'state/_partial/art_object'
require 'state/_partial/element'
require 'state/_partial/tag'
require 'state/_partial/form'
require 'state/_partial/status'
require 'state/_partial/image'
require 'state/_partial/guest'

module DaVaz::State
  module Admin

    EVENT_MAP = {
      :art_object             => AdminArtObject,
      :new_art_object         => AdminArtObject,
      :ajax_add_element       => AdminAjaxAddNewElement,
      :ajax_add_form          => AdminAjaxAddForm,
      :ajax_all_tags          => AdminAjaxAllTags,
      :ajax_all_tags_link     => AdminAjaxAllTagsLink,
      :ajax_remove_element    => AdminAjaxRemoveElement,
      :ajax_delete_element    => AdminAjaxDeleteElement,
      :ajax_delete_guest      => AdminAjaxDeleteGuest,
      :ajax_delete_image      => AdminAjaxDeleteImage,
      :ajax_save_live_edit    => AdminAjaxSaveLiveEdit,
      :ajax_save_gb_live_edit => AdminAjaxSaveGbLiveEdit,
      :ajax_upload_image      => AdminAjaxUploadImage,
      :ajax_upload_image_form => AdminAjaxUploadImageForm,
      :ajax_movie_gallery     => Works::AdminAjaxMovieGallery,
      :design                 => Works::AdminDesign,
      :drawings               => Works::AdminDrawings,
      :movies                 => Works::AdminMovies,
      :paintings              => Works::AdminPaintings,
      :photos                 => Works::AdminPhotos,
      :schnitzenthesen        => Works::AdminSchnitzenthesen,
      :gallery                => Gallery::AdminGallery,
      :guestbook              => Communication::AdminGuestbook,
      :links                  => Communication::AdminLinks,
      :news                   => Communication::AdminNews,
      :work                   => Personal::AdminWork,
      :life                   => Personal::AdminLife
    }

    def ajax_desk
      if @session.user_input(:artobject_id)
        Gallery::AdminAdminDeskArtobject.new(@session, [])
      else
        Gallery::AjaxDesk.new(@session, [])
      end
    end

    def ajax_check_removal_status
      AdminAjaxCheckRemovalStatus.new(@session, [])
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
      Redirect.new(@session, model)
    end
  end
end
