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
require 'state/_partial/art_object'
require 'state/_partial/admin_parts'

module DaVaz::State
  module AdminMethods

    EVENT_MAP = {
      :art_object             => Admin::ArtObject,
      :new_art_object         => Admin::ArtObject,
      :ajax_add_element       => Admin::AjaxAddElement,
      :ajax_add_form          => Admin::AjaxAddForm,
      :ajax_all_tags          => Admin::AjaxAllTags,
      :ajax_all_tags_link     => Admin::AjaxAllTagsLink,
      :ajax_remove_element    => Admin::AjaxRemoveElement,
      :ajax_delete_element    => Admin::AjaxDeleteElement,
      :ajax_delete_guest      => Admin::AjaxDeleteGuest,
      :ajax_delete_image      => Admin::AjaxDeleteImage,
      :ajax_save_live_edit    => Admin::AjaxSaveLiveEdit,
      :ajax_save_gb_live_edit => Admin::AjaxSaveGbLiveEdit,
      :ajax_upload_image      => Admin::AjaxUploadImage,
      :ajax_upload_image_form => Admin::AjaxUploadImageForm,
      :ajax_movie_gallery     => Works::AjaxAdminMovieGallery,
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
        Gallery::AjaxAdminDeskArtobject.new(@session, [])
      else
        Gallery::AjaxDesk.new(@session, [])
      end
    end

    def ajax_check_removal_status
      Admin::AjaxCheckRemovalStatus.new(@session, [])
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
