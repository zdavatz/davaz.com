require 'htmlgrid/divcomposite'
require 'view/works/init'
require 'view/template'

module DaVaz::View
  module Works
    class SchnitzenthesenComposite < Init; end

    class Schnitzenthesen < SchnitzenthesenTemplate
      CONTENT = SchnitzenthesenComposite
    end

    class AdminSchnitzenthesen < AdminSchnitzenthesenTemplate
      CONTENT = SchnitzenthesenComposite
    end
  end
end
