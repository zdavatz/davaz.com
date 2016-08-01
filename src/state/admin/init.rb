require 'state/admin/global'
require 'view/admin/init'

module DaVaz::State
  module Admin
    class Init < Global
      VIEW = DaVaz::View::Admin::Init
    end
  end
end
