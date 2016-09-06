require 'sbsm/state'
require 'sbsm/viralstate'
require 'htmlgrid/component'

# This file exists to avoid cycle dependencies.
# Note load timing and make sure the includeness of modules.
module DaVaz::State
  class Global < SBSM::State; end

  # partial
  module Admin
    include SBSM::ViralState
  end

  class Tooltip < DaVaz::State::Global; end

  module Gallery
    class Global    < DaVaz::State::Global; end
    class Init      < DaVaz::State::Gallery::Global; end
    class Result    < DaVaz::State::Gallery::Global; end
    class ArtObject < DaVaz::State::Gallery::Global; end
  end

  module Personal
    class Global      < DaVaz::State::Global; end
    class Init        < DaVaz::State::Personal::Global; end
    class Work        < DaVaz::State::Personal::Global; end
    class Life        < DaVaz::State::Personal::Global; end
    class Inspiration < DaVaz::State::Personal::Global; end
    class Family      < DaVaz::State::Personal::Global; end
    class TheFamily   < DaVaz::State::Personal::Global; end
  end

  module Works
    class Global          < DaVaz::State::Global; end
    class Rack            < DaVaz::State::Works::Global; end
    class Design          < DaVaz::State::Works::Rack; end
    class Drawings        < DaVaz::State::Works::Rack; end
    class Movies          < DaVaz::State::Works::Global; end
    class Multiples       < DaVaz::State::Works::Rack; end
    class Paintings       < DaVaz::State::Works::Rack; end
    class Photos          < DaVaz::State::Works::Rack; end
    class Schnitzenthesen < DaVaz::State::Works::Rack; end
  end

  module Communication
    class Global         < DaVaz::State::Global; end
    class Guestbook      < DaVaz::State::Communication::Global; end
    class GuestbookEntry < DaVaz::State::Communication::Global; end
    class Links          < DaVaz::State::Communication::Global; end
    class News           < DaVaz::State::Communication::Global; end
    class Shop           < DaVaz::State::Communication::Global; end
    class ShopThanks     < DaVaz::State::Communication::Global; end
  end

  module Public
    class Global        < DaVaz::State::Global; end
    class Articles      < DaVaz::State::Public::Global; end
    class AjaxArticle   < SBSM::State; end
    class Exhibitions   < DaVaz::State::Public::Global; end
    class GallerySearch < DaVaz::State::Public::Global; end
    class Lectures      < DaVaz::State::Public::Global; end
  end
end
