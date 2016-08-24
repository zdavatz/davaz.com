require 'sbsm/lookandfeel'
require 'yaml'

module DaVaz::Util
  class Lookandfeel < SBSM::Lookandfeel
    LANGUAGES = ['en']

    DICTIONARIES = {
      'en' => {
        # a
        a_divider:              '&nbsp;&aacute;&nbsp;',
        add_country:            'Add New Country',
        add_element:            'Add New Element',
        add_image:              'Add Image',
        add_link:               'Add Link',
        add_material:           'Add New Material',
        add_serie:              'Add New Serie',
        add_tool:               'Add New Tool',
        address:                'Address',
        ajax_add_link:          'Add Link',
        ajax_add_new_element:   'Add',
        ajax_save_live_edit:    'Save',
        ajax_upload_image:      'Upload Image',
        ajax_submit_entry:      'Submit entry',
        all_entries:            'All Entries',
        art_object:             'Art Object',
        artgroup:               'Artgroup',
        artgroup_id:            'Artgroup',
        ask_for_image_deletion: 'Do you really want to delete this image?',
        author:                 'Author',
        # b
        back:             '<< Back',
        back_to_overview: 'Back To Overview',
        back_to_shop:     'Back To Shop',
        blog:             'Blog',
        bottleneck:       'Bottleneck',
        br:               '<br />',
        # c
        cancel:              'Cancel',
        change_of_times:     'Change of times<br>1990 - 2000',
        choose_image:        'Choose an existing image',
        click2edit:          'Please click here to edit.',
        click2edit_textarea: 'Please click here to edit the textarea.',
        contact_email:       'Email',
        country:             'Country',
        country_id:          'Country',
        charset:             'Charset',
        chinese:             'Chinese',
        city:                'City',
        close:               'Close',
        close_article:       'Close article',
        close_window:        'Close window',
        close_window_href:   'javascript:window.close()',
        comma_divider:       ',&nbsp;',
        copyright:           "LGPL ywesee #{Time.now.year}",
        copyright_url:       'http://scm.ywesee.com/?p=davaz.com;a=summary',
        # d
        dash_divider:    '&nbsp;-&nbsp;',
        date:            'Date',
        date_gb:         'Date',
        davaz_guestbook: 'The da vaz guestbook',
        davaz_shop:      'The da vaz shop',
        delete:          'Delete item',
        delete_image:    'Delete image',
        # e
        e_authentication_error:     'Login failed!',
        e_domainless_email_address: 'Sorry, but your email-address seems to ' \
                                    'be invalid. please try again.',
        e_incorrect_login:          'Login failed! invalid username or ' \
                                    'password. Please try again.',
        e_invalid_date:             'Invalid day format. Please use e.g. ' \
                                    '01.01.2006',
        e_invalid_email_address:    'Sorry, but your email-address seems to ' \
                                    'be invalid. Please try again.',
        e_invalid_postal_code:      'Your postal code seems to be invalid.',
        e_invalid_serie_id:         'Sorry that is an invalid serie_id.',
        e_invalid_zone:             'Sorry that is an invalid zone.',
        e_missing_fields:           'Please fill out the fields that are ' \
                                    'marked with red.',
        e_missing_name:             'Please enter a name.',
        e_missing_surname:          'Please enter a surame.',
        e_missing_email:            'Please enter a email address.',
        e_missing_city:             'Please enter a city.',
        e_missing_country:          'Please enter a country.',
        e_missing_messagetxt:       'Please enter a message.',
        e_not_good_for_removal:     'There are other artobjects assigned to ' \
                                    'this element. Please assign them to ' \
                                    'another element first.',
        early_years:                'Early years<br>1946-1957',
        edit:                       'Edit',
        edit_element:               'Edit element',
        email:                      'Email',
        email_juerg:                'juerg@davaz.com',
        english:                    'English',
        equal_divider:              '&nbsp;=&nbsp;',
        eyesharpener:               'Eyesharpener',
        # f
        family_of_origin: 'His Family of Origin',
        # g
        guestbook:      'Guestbook',
        guestbook_info: 'Please add your comments.<br>I greatly appreciate ' \
                        'your op on and further information.<br><br>' \
                        'Thank you!',
        # h
        heartbeat:         'Heartbeat',
        hide:              'Hide',
        history_back_link: '<a href=\'javascript:history.go(-1)\' ' \
                           'onmouseover=\'self.status=document.referrer;' \
                           'return true\'>go back</a>',
        home:              'Home',
        html_title:        'Da Vaz - Abstract Artist from Switzerland',
        hungarian:         'Dungarian',
        hunting:           'Dunting',
        # i
        image_file:        'Image file',
        image_title:       'Image title',
        imagination:       'Imagination',
        india_ticker_link: 'Passage through India: One of Da Vaz\'s ' \
                           'memorable trips',
        init_drawing:      'Drawing',
        intro_text:        <<~TEXT.gsub(/\n/, ''),
          Swiss-born artist da vaz does not wait for
          the right<br>moment. He could be totally unprepared himself when
          his<br>adrenaline surges up. His searching eyes look for
          details<br>from where he culls new meanings, new expressions.<br>
          and give life to his indigenous art form.
        TEXT
        item_s:            'Item(s)',
        items_in_cart:     'Item(s) in cart',
        # j
        journey: 'Journey',
        # l
        language:         'Language',
        links:            'Links',
        links_from_davaz: 'Links from da vaz',
        location:         'Location',
        login:            'Login',
        login_email:      'Email',
        login_form:       'Login',
        login_password:   'Password',
        logout:           'Logout',
        # m
        manage_links:            'Manage text links',
        material:                'Material',
        material_id:             'Material',
        messagetxt:              'Message',
        more:                    'More...',
        morphopolis_ticker_link: 'MOVIE: M O R P H O P O L I S, Da Vaz`s ' \
                                 'outstanding: Vision of Publicspace',
        movie:                   'Movie',
        movies:                  'Movies',
        movie_link:              ':: watch :: eyesharpener Da Vaz movies',
        movie_page:              ' ::  movie page',
        # n
        name:                'Name',
        nbsp:                '&nbsp',
        new_art_object:      'New art object',
        new_element:         'Add new element',
        new_entry:           'New entry',
        new_guestbook_entry: 'New guestbook entry',
        news:                'News',
        news_from_davaz:     'News from da vaz',
        next:                'Next >>',
        no_items:            'No items found.',
        no_name:             '',
        no_works:            'There are no works in this category yet.',
        # o
        order_item: 'Order item(s)',
        # p
        photo_davaz:          'Photo of J&uuml;rg DaVaz',
        pic_bottleneck:       'Link to Bottleneck',
        pic_family:           'Link to Family',
        pic_inpiration:       'Link to Inpiration',
        pipe_divider:         '|',
        player_download_text: 'Free download:',
        please_select:        'Please select...',
        position:             'Position',
        postal_code:          'Postal Code',
        posters:              'Posters',
        private_life:         'Private Life<br>1975 - 1989',
        price:                'Price in CHF',
        publications:         'Publications',
        # q
        quicktime_player:   'Quicktime Player',
        quicktime_download: 'http://www.apple.com/quicktime/download/',
        # r
        read_on:             'Read on...',
        read_wordpress:      'Read more about this work of art and leave ' \
                             'a comment at Godzilla\'s Blog!',
        realone_player:      'Realone Player',
        realplayer_download: 'http://europe.real.com/freeplayer_r1p.html?' \
                             '&src=zg.eu.idx.idx.sw.chc',
        remember_me:         'Remember me',
        remove:              'Remove',
        remove_all_items:    'Remove all items',
        remove_country:      'Remove selected country',
        remove_element:      'Remove element',
        remove_image:        'Remove image',
        remove_item:         'Remove item',
        remove_link:         'Remove link',
        remove_material:     'Remove selected material',
        remove_serie:        'Remove selected serie',
        remove_tool:         'Remove selected tool',
        reset:               'Reset',
        russian:             'Russian',
        # s
        save:              'Save',
        sculptures:        'Sculptures',
        search:            'Search',
        search_reset:      'Reset',
        send_order:        'Send order',
        serie:             'Serie',
        serie_id:          'Serie',
        serie_position:    'Serie position',
        shop:              'Shop',
        shop_mail_salut:   "Hi!\n\nThe following order has been sent:",
        shop_mail_bye:     "Thank you very much for your interest in my " \
                           "site and your order.\n\nWith best regards\n\n" \
                           "j. davatz",
        shop_thanks:       'Your order has been succesfully sent.' \
                           '<br>Thank you very much.',
        shopping_cart:     'Shopping cart',
        show_tags:         'Show all tags',
        signature:         'Signature',
        size:              'Size',
        slash_divider:     '&nbsp;/&nbsp;',
        space_divider:     '&nbsp;',
        street:            'Street',
        submit:            'Submit',
        successfull_login: 'You have been successfully logged in.',
        surname:           'Surname',
        # t
        tags:                'Tags',
        text:                'Text',
        th_artgroup:         'Artgroup',
        th_count:            'Item(s)',
        th_dollars:          '&agrave; $',
        th_franks:           '&agrave; CHF',
        th_name:             'Item',
        th_subtotal_dollars: 'Subtotal $',
        th_subtotal_franks:  'subtotal CHF',
        the_family:          'The Family',
        the_family_title:    'The Family',
        title:               'Title',
        title_divider:       ' | ',
        time_of_change:      'Times of Change<br>1965 - 1975',
        times_divider:       '&nbsp;x&nbsp;',
        tool:                'Tool',
        tool_id:             'Tool',
        total:               'Total',
        # u
        url:                'URL',
        username:           'Username',
        update:             'Update',
        upload_image:       'Upload image',
        upload_image_title: 'Upload an image for this element',
        # w
        watch_movie:   'Watch the movie',
        webcontent:    'Webcontent',
        wordpress_url: 'Wordpress',
        # y
        ywesee_url: 'http://www.ywesee.com',

        # navigation
        # top
        life:        'HIS LIFE',
        work:        'HIS WORK',
        inspiration: 'HIS INSPIRATION',
        family:      'HIS FAMILY',
        # side
        drawings:        'Drawings',
        paintings:       'Paintings',
        multiples:       'Multiples',
        photos:          'Photos',
        design:          'Design',
        schnitzenthesen: 'Schnitzenthesen',
        gallery:         'Gallery',
        articles:        'Articles',
        lectures:        'Lectures',
        exhibitions:     'Exhibitions',
      }
    }

    RESOURCES = {
      # css
      admin_css:               'css/admin.css',
      articles_css:            'css/articles.css',
      css:                     'css/davaz.css',
      communication_css:       'css/communication.css',
      communication_admin_css: 'css/communication_admin.css',
      design_css:              'css/design.css',
      drawings_css:            'css/drawings.css',
      exhibitions_css:         'css/exhibitions.css',
      gallery_css:             'css/gallery.css',
      images_css:              'css/images.css',
      init_css:                'css/init.css',
      lectures_css:            'css/lectures.css',
      multiples_css:           'css/multiples.css',
      navigation_css:          'css/navigation.css',
      paintings_css:           'css/paintings.css',
      personal_css:            'css/personal.css',
      photos_css:              'css/photos.css',
      schnitzenthesen_css:     'css/schnitzenthesen.css',
      tooltip_css:             'css/tooltip.css',
      movies_css:              'css/movies.css',
      # images
      desk:                 'images/global/desk.gif',
      family_title:         'images/global/family.gif',
      gallery_search_title: 'images/global/gallery_search.gif',
      icon_add:             'images/global/icons/add.png',
      icon_cancel:          'images/global/icons/cancel.png',
      icon_delete:          'images/global/icons/delete.png',
      icon_toparrow:        'images/global/icons/toparrow.gif',
      init_drawing:         'images/init/drawing.jpg',
      inspiration_title:    'images/global/inspiration.gif',
      logo_ph:              'images/global/davaz_logo_ph.gif',
      paging_last:          'images/global/paging_last.gif',
      paging_next:          'images/global/paging_next.gif',
      paypal_donate:        'images/global/paypal_donate.gif',
      pause:                'images/global/pause.gif',
      photo_davaz:          'images/init/photo_davaz.jpg',
      pic_bottleneck:       'images/init/bottleneck.jpg',
      pic_family:           'images/init/family.jpg',
      pic_inspiration:      'images/init/inspiration.jpg',
      play:                 'images/global/play.gif',
      play_large_movie:     'images/global/large_movie.png',
      play_small_movie:     'images/global/small_movie.png',
      rack:                 'images/global/rack.gif',
      series_title:         'images/global/series.gif',
      slide:                'images/global/show.gif',
      signature:            'images/init/signature.gif',
      topleft_ph:           'images/global/topleft_ph.gif',
      work_title:           'images/global/work.gif',
      # uploads
      cv_russian:  'uploads/pdf/hislife/cv_russian.pdf',
      tmp_uploads: 'uploads/tmp/',
      # other
      dojo_js:    'dojo/dojo/dojo.js',
      javascript: 'javascript',
      ram_files:  'movies/ram_files'
    }

    def base_url(zone=@session.zone)
      [
        @session.http_protocol + ':/',
        @session.server_name,
        @language,
        zone
      ].compact.join('/')
    end

    def event_url(zone=@session.zone, event=:home, args={})
      args = Array(args).collect { |*pair| pair }.flatten
      [base_url(zone), event, args].compact.join('/')
    end

    def foot_navigation(filter=false)
      @session.foot_navigation
    end

    def resource_path(rname, rstr)
      dir = collect_resource([self::class::RESOURCE_BASE], rname, rstr)
      File.expand_path("../../doc" + dir, File.dirname(__FILE__))
    end

    def stream_url(id, size)
      filename = "#{id.to_s}_#{size.to_s.downcase}.ram"
      if File.exist?(resource_path(:ram_files, filename))
        arr = [resource_global(:ram_files), filename]
        arr.compact.join('/')
      else
        nil
      end
    end

    def top_navigation(filter=false)
      @session.top_navigation
    end

    def set_dictionary(language)
      super
      @dictionary
    end
  end
end
