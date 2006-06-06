#!/usr/bin/env ruby
# State::GlobalPredefine -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/state'
require 'htmlgrid/component'

module DAVAZ
	module State
		class Global < SBSM::State; end
		module Communication
class Global < State::Global; end
class Guestbook < State::Communication::Global; end
class GuestbookEntry < State::Communication::Global; end
class Links < State::Communication::Global; end
class News < State::Communication::Global; end
class Shop < State::Communication::Global; end
class ShopThanks < State::Communication::Global; end
		end
		module Gallery
class Global < State::Global; end
class Search < State::Gallery::Global; end
		end
		module Personal 
class Global < State::Global; end
class Family < State::Personal::Global; end
class Init < State::Personal::Global; end
class Inspiration < State::Personal::Global; end
class Life < State::Personal::Global; end
class TheFamily < State::Personal::Global; end
class Work < State::Personal::Global; end
		end
		module Works
class Global < State::Global; end
class Design < State::Works::Global; end
class Drawings < State::Works::Global; end
class Movies < State::Works::Global; end
class Multiples < State::Works::Global; end
class Paintings < State::Works::Global; end
class Photos < State::Works::Global; end
class Schnitzenthesen < State::Works::Global; end
		end
		module Public
class Global < State::Global; end
class Articles < State::Public::Global; end
class Exhibitions < State::Public::Global; end
class GallerySearch < State::Public::Global; end
class Lectures < State::Public::Global; end
		end
		module ToolTip
class Global < State::Global; end
class Poem < State::ToolTip::Global; end
class Image < State::ToolTip::Global; end
class Artobject < State::ToolTip::Global; end
		end
	end
end
