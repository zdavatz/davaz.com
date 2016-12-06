require 'sbsm/validator'
require 'cgi'

module DaVaz::Util
  class Validator < SBSM::Validator
    ALLOWED_TAGS = %{
      a b br div font h1 h2 h3 i img li ol p pre strong u ul
      embed object param
    }
    BOOLEAN = %i{remember_me}
    DATES   = %i{date date_ch}
    EVENTS = %i{
      ajax_add_element
      ajax_add_form
      ajax_add_link
      ajax_add_new_element
      ajax_all_tags
      ajax_all_tags_link
      ajax_article
      ajax_cancel_live_edit
      ajax_check_removal_status
      ajax_delete_element
      ajax_delete_guest
      ajax_delete_image
      ajax_delete_link
      ajax_delete_oneliner
      ajax_delete_tooltip
      ajax_desk
      ajax_desk_artobject
      ajax_guestbookentry
      ajax_submit_entry
      ajax_home
      ajax_images
      ajax_image_action
      ajax_reload_tag_images
      ajax_live_edit_form
      ajax_movie_gallery
      ajax_multiples
      ajax_rack
      ajax_remove_element
      ajax_save_live_edit
      ajax_save_gb_live_edit
      ajax_save_ol_live_edit
      ajax_save_tp_live_edit
      ajax_shop
      ajax_upload_image
      ajax_upload_image_form
      article
      articles
      art_object
      back
      bottleneck
      data_url
      delete
      design
      drawings
      edit
      exhibitions
      family
      flush_ajax_errors
      gallery
      guestbook
      home
      inspiration
      lectures
      life
      links
      login
      login_form
      logout
      multiples
      new
      new_art_object
      news
      oneliners
      paintings
      personal_life
      photos
      remove_all_items
      schnitzenthesen
      search
      send_order
      shop
      shop_art_object
      shop_thanks
      shopitem
      the_family
      tooltip
      tooltips
      update
      upload_image
      movies
      work
    }
    FILES = %i{image_file}
    HTML  = %i{text update_value}
    ZONES = %i{
      admin
      communication
      gallery
      personal
      public
      stream
      tooltip
      works
    }
    STRINGS = %i{
      article
      address
      artgroup_id
      author
      breadcrumbs
      city
      color
      charset
      country
      country_id
      event
      form_artgroup_id
      form_language
      fragment
      guest_id
      image_title
      fields
      field_key
      lang
      language
      link_word
      location
      login_email
      login_password
      material_id
      messagetxt
      name
      node_id
      object_type
      old_serie_id
      oneliner_id
      price
      remember
      search_query
      select_name
      select_value
      selected_id
      serie_id
      serie_position
      size
      street
      surname
      table
      tags
      tags_to_s
      target
      text
      title
      tool_id
      url
      wordpress_url
      word
    }
    NUMERIC = %i{
      artobject_id
      linked_artobject_id
      count
      size
      link_id
      parent_link_id
      postal_code
    }

    def serie_id(value)
      if /[A-Z]/.match(value)
        value
      else
        raise SBSM::InvalidDataError.new(:e_invalid_zone_id, :dose, value)
      end
    end

    def show(value)
      value
    end

    def zone(value)
      zone_value = validate_string(value).to_s
      if zone_value.empty?
        raise SBSM::InvalidDataError.new('e_invalid_zone', :zone, value)
      end
      zone_sym = zone_value.intern
      if self::class::ZONES.include?(zone_sym)
        zone_sym
      else
        raise SBSM::InvalidDataError.new('e_invalid_zone', :zone, value)
      end
    end
  end
end
