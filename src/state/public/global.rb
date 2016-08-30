require 'state/global'
require 'state/personal/init'
require 'state/public/articles'
require 'state/public/exhibitions'
require 'state/public/lectures'

module DaVaz::State
  module Public
    class Global < DaVaz::State::Global
      HOME_STATE = Personal::Init
      ZONE       = :public
      EVENT_MAP  = {
        :ajax_article => AjaxArticle,
        :articles     => Articles,
        :exhibitions  => Exhibitions,
        :lectures     => Lectures
      }
    end
  end
end
