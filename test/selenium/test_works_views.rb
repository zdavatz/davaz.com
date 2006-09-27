#!/usr/bin/env ruby
# SeleniumTests -- davaz.com -- 26.09.2006 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'test/selenium/unit'

class TestWorksViews < Test::Unit::TestCase
	include DAVAZ::Selenium::TestCase
  def test_test_works_views
    @selenium.open "/en/communication/links/"
    @selenium.click "link=Drawings"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Drawings", @selenium.get_title
    @selenium.mouse_over "201"
    sleep 1
    assert @selenium.is_text_present("In rauhen Zeiten lohnt sich die geschlechtliche")
    assert @selenium.is_text_present("Heuhaufen, body plans")

    # <tr>
    # 	<td>clickAndWait</td>
    # 	<td>link=body plans,</td>
    # 	<td></td>
    # </tr>
    # <tr>
    # 	<td>assertLocation</td>
    # 	<td>/en/works/drawings/serie_id/ABE</td>
    # 	<td></td>
    # </tr>


    @selenium.click "link=Paintings"

    @selenium.wait_for_page_to_load "30000"

    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Paintings", @selenium.get_title

    assert @selenium.is_text_present("Varanasi")


    # <tr>

    # 	<td>clickAndWait</td>

    # 	<td>link=Varanasi,</td>

    # 	<td></td>

    # </tr>

    # <tr>

    # 	<td>assertLocation</td>

    # 	<td>/en/works/paintings/serie_id/AAT</td>

    # 	<td></td>

    # </tr>



    @selenium.click "link=Multiples"


    @selenium.wait_for_page_to_load "30000"


    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Multiples", @selenium.get_title


    assert @selenium.is_text_present("Multiples")


    @selenium.click "link=Movies"


    @selenium.wait_for_page_to_load "30000"


    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title


    assert @selenium.is_text_present("HUMUS for HAMAS")


    @selenium.click "//a[@name='more' and @onclick=\"showMovieGallery('movies-gallery-view', 'movies-list', 'http://new.davaz.com/en/gallery/ajax_movie_gallery/artobject_id/663')\"]"


    sleep 5


    begin




        assert @selenium.is_text_present("Damascus, Syria")


    rescue Test::Unit::AssertionFailedError




        @verification_errors << $!


    end


    @selenium.click "paging_next"


    begin




        assert @selenium.is_text_present("All of my family watched Humus")


    rescue Test::Unit::AssertionFailedError




        @verification_errors << $!


    end


    @selenium.click "link=Back To Overview"


    sleep 5


    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Movies", @selenium.get_title


    @selenium.click "link=Photos"


    @selenium.wait_for_page_to_load "30000"


    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Photos", @selenium.get_title


    assert @selenium.is_text_present("Ancestors")



    # <tr>


    # 	<td>clickAndWait</td>


    # 	<td>link=Ancestors,</td>


    # 	<td></td>


    # </tr>


    # <tr>


    # 	<td>assertLocation</td>


    # 	<td>/en/works/photos/serie_id/ABT</td>


    # 	<td></td>


    # </tr>




    @selenium.click "link=Design"



    @selenium.wait_for_page_to_load "30000"



    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Design", @selenium.get_title



    assert @selenium.is_text_present("Design")



    @selenium.click "link=Schnitzenthesen"



    @selenium.wait_for_page_to_load "30000"



    assert_equal "Da Vaz - Abstract Artist from Switzerland | Works | Schnitzenthesen", @selenium.get_title



    assert @selenium.is_text_present("collage")




    # <tr>



    # 	<td>clickAndWait</td>



    # 	<td>link=collage,</td>



    # 	<td></td>



    # </tr>



    # <tr>



    # 	<td>assertLocation</td>



    # 	<td>/en/works/schnitzenthesen/serie_id/AAR</td>



    # 	<td></td>



    # </tr>

  end
end
