require 'state/predefine'
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
        :ajax_article => DaVaz::State::Public::AjaxArticle,
        :articles     => DaVaz::State::Public::Articles,
        :exhibitions  => DaVaz::State::Public::Exhibitions,
        :lectures     => DaVaz::State::Public::Lectures
      }
    end
  end
end
