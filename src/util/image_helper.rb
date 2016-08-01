require 'fileutils'
require 'rmagick'
require "util/config"

module DaVaz::Util
  class ImageHelper
    include Magick

    @@geometries = {
      :small  => Geometry.new(DaVaz.config.small_image_width.to_i),
      :medium => Geometry.new(DaVaz.config.medium_image_width.to_i),
      :large  => Geometry.new(DaVaz.config.large_image_width.to_i),
      :slide  => Geometry.new(nil, DaVaz.config.show_image_height.to_i)
    }

    class << self
      def image_path(artobject_id, size=nil)
        pattern = File.join(
          image_dir(size),
          artobject_id.to_s[-1,1],
          artobject_id.to_s + '.*'
        )
        Dir.glob(pattern).first
      end

      def delete_image(artobject_id)
        path = image_path(artobject_id)
        File.unlink(path) if path
        @@geometries.each { |key, value|
          path = image_path(artobject_id, key)
          File.unlink(path) if path
        }
      end

      def has_image?(artobject_id)
        image_path(artobject_id)
      end

      def tmp_image_dir
        dir_components = [
          DaVaz.config.document_root,
          DaVaz.config.uploads_dir,
          'tmp/images'
        ]
        dir_components.join('/')
      end

      def image_dir(size=nil)
        dir_components = [
          DaVaz.config.document_root,
          DaVaz.config.uploads_dir,
          'images'
        ]
        dir_components.push(size) if size
        dir_components.join('/')
      end

      def image_url(artobject_id, size=nil, timestamp=false)
        return nil unless artobject_id
        path = image_path(artobject_id, size)
        return nil unless path
        if timestamp
          path += sprintf('?time=%i', File.mtime(path))
        end
        if path
          path.slice!(DaVaz.config.document_root)
          path
        end
      end

      def resize_image(artobject_id, image)
        @@geometries.each { |key, value|
          image.change_geometry(value) { |cols, rows, img|
            store_image(artobject_id, img.resize(cols, rows), key)
          }
        }
      end

      def store_image(artobject_id, image, key=nil)
        path = image_dir(key.to_s)
        directory = artobject_id[-1,1]
        image.write([
          path,
          directory,
          "#{artobject_id}.#{image.format.downcase}",
        ].join('/'))
      end

      def store_upload_image(string_io, artobject_id)
        delete_image(artobject_id) if has_image?(artobject_id)
        image = Image.from_blob(string_io.read).first
        extension = image.format.downcase
        path = File.join(
          image_dir,
          artobject_id.to_s[-1,1],
          artobject_id.to_s + '.' + extension
        )
        image.write(path)
        resize_image(artobject_id.to_s, image)
      end

      def store_tmp_image(tmp_path, artobject_id)
        image = Image.read(tmp_path).first
        extension = image.format.downcase
        dir = File.join(image_dir, artobject_id.to_s[-1,1])
        FileUtils.mkdir_p(dir)
        path = File.join(dir, artobject_id.to_s + '.' + extension)
        image.write(path)
        resize_image(artobject_id.to_s, image)
        File.delete(tmp_path)
      end
    end
  end
end
