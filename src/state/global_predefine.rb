#!/usr/bin/env ruby
# State::GlobalPredefine -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

require 'sbsm/state'
require 'htmlgrid/component'

module DAVAZ
	module State
		class Global < SBSM::State; end
		module Admin
class Global < State::Global; end
class Home < State::Admin::Global; end
class ImageChooser < State::Admin::Global; end
class AjaxAddNewElement < SBSM::State; end
		end
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
class Home < State::Gallery::Global; end
class Result < State::Gallery::Global; end
class ArtObject < State::Gallery::Global; end
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
class RackState < State::Works::Global; end
class Design < State::Works::RackState; end
class Drawings < State::Works::RackState; end
class Movies < State::Works::Global; end
class Multiples < State::Works::RackState; end
class Paintings < State::Works::RackState; end
class Photos < State::Works::RackState; end
class Schnitzenthesen < State::Works::RackState; end
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
