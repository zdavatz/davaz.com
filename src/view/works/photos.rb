require 'view/template'
require 'view/works/init'

module DaVaz::View
  module Works
    class PhotosComposite < Init; end

    class Photos < PhotosTemplate
      CONTENT = PhotosComposite
    end

    # @api admin
    class AdminPhotos < AdminPhotosTemplate
      CONTENT = PhotosComposite
    end
  end
end
