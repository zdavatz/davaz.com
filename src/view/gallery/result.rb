require 'htmlgrid/divlist'
require 'htmlgrid/divform'
require 'view/template'
require 'view/_partial/list'
require 'view/_partial/navigation'
require 'view/gallery/init'

module DaVaz
  module View
    module Gallery
      class ResultList < View::List
        CSS_CLASS    = 'result-list'
        STRIPED_BG   = true
        SORT_DEFAULT = :title
        SORT_REVERSE = true
        COMPONENTS   = {
          [0, 0] => :title,
          [1, 0] => :year,
          [2, 0] => :tool,
          [3, 0] => :material,
          [4, 0] => :size,
          [5, 0] => :country,
          [6, 0] => :serie
        }
        CSS_MAP = {
          [0, 0] => 'result-title',
          [1, 0] => 'result-year',
          [2, 0] => 'result-tool',
          [3, 0] => 'result-material',
          [4, 0] => 'result-size',
          [5, 0] => 'result-country',
          [6, 0] => 'result-serie'
        }

        def title(model)
          args = [[:artobject_id, model.artobject_id]]
          search_query = @session.user_input(:search_query)
          args.unshift([:search_query, search_query]) if search_query

          artgroup_id = @session.user_input(:artgroup_id)
          args.unshift([:artgroup_id, artgroup_id]) if artgroup_id

          link = HtmlGrid::Link.new(:title, @model, @session, self)
          link.href  = @lookandfeel.event_url(:gallery, :art_object, args)
          link.value = model.title
          link.value = model.artobject_id if link.value.empty?
          link
        end

        def year(model)
          date = model.date
          begin
            date = Date.parse(date) unless date.is_a?(Date)
            date.year
          rescue ArgumentError, TypeError
            'n.a.'
          end
        end

        def compose_header(offset=[0,0])
          table_title = (@model.first.artgroup || 'Unknown') + \
            " (#{@model.size})"
          @grid.add(table_title, 0, 0)
          @grid.add_tag('TH', 0, 0)
          @grid.set_colspan(0, 0, full_colspan)
          resolve_offset(offset, [0,1])
        end
      end

      class ResultColumnNames < View::Composite
        CSS_ID     = 'result-list-column-names'
        COMPONENTS = {
          [0, 0] => 'title',
          [1, 0] => 'year',
          [2, 0] => 'tool',
          [3, 0] => 'material',
          [4, 0] => 'size',
          [5, 0] => 'country',
          [6, 0] => 'serie'
        }
        CSS_MAP = {
          [0, 0] => 'result-title',
          [1, 0] => 'result-year',
          [2, 0] => 'result-tool',
          [3, 0] => 'result-material',
          [4, 0] => 'result-size',
          [5, 0] => 'result-country',
          [6, 0] => 'result-serie'
        }
      end

      class NewSearch < HtmlGrid::DivForm
        CSS_CLASS  = ''
        COMPONENTS = {
          [2,0] => :search_query,
          [3,0] => :submit
        }
        SYMBOL_MAP = {
          :search_query => InputBar
        }
        EVENT       = :search
        FORM_METHOD = 'POST'

        def init
          self.onload = "document.getElementById('searchbar').focus();"
          super
        end

        def all_entries(model)
          args = [[:search_query, :all_entries]]
          artgroup_id = @session.user_input(:artgroup_id)
          args.unshift([ :artgroup_id, artgroup_id]) if artgroup_id

          button = HtmlGrid::Button.new(:all_entries, @model, @session, self)
          button.set_attribute('onclick', <<~EOS)
            document.location.href='#{ \
              @lookandfeel.event_url(:gallery, :search, args)}';
          EOS
          button
        end
      end

      class EmptyResultList < HtmlGrid::Div
        CSS_ID = 'empty-result-list'

        def init
          super
          @value = @lookandfeel.lookup(:no_items)
        end
      end

      class ResultComposite < HtmlGrid::DivComposite
        COMPONENTS = {
          [0, 0] => View::GalleryNavigation,
          [0, 1] => NewSearch,
          [0, 2] => ResultColumnNames,
          [0, 3] => :result_list
        }
        CSS_ID_MAP = {
          0 => 'gallery-navigation',
          1 => 'new-search'
        }

        def result_list(model)
          tables = model.artgroups.map { |grp|
            artgroup_items = model.result.select { |item|
              item.artgroup_id == grp.artgroup_id
            }
            unless artgroup_items.empty?
              ResultList.new(artgroup_items, @session, self)
            end
          }.compact
          return EmptyResultList.new(model, @session, self) \
            if tables.length <= 0
          tables
        end
      end

      class Result < View::GalleryTemplate
        CONTENT = View::Gallery::ResultComposite
      end

      class RackResultList < ResultList
        SORT_DEFAULT = nil
        SORT_REVERSE = false

        def title(model)
          serie_id     = @session.user_input(:serie_id)
          artobject_id = model.artobject_id
          url = @lookandfeel.event_url(:gallery, :ajax_rack, [
            [:artgroup_id,  model.artgroup_id],
            [:serie_id,     serie_id],
            [:artobject_id, artobject_id],
          ])
          link = HtmlGrid::Link.new(:title, @model, @session, self)
          link.value = model.title
          link.value = model.artobject_id if model.title.empty?
          link.href  = 'javascript:void(0)'
          link.set_attribute('onclick', <<~EOS)
            toggleShow('show', '#{url}', 'desk',
              'show_wipearea', '#{serie_id}', '#{artobject_id}');
          EOS
          link
        end
      end

      class RackResultListInnerComposite < HtmlGrid::DivComposite
        COMPONENTS = {
          [0, 0] => ResultColumnNames,
          [0, 1] => :result_list
        }
        def result_list(model)
          if model.size <= 0
            EmptyResultList.new(model, @session, self)
          else
            RackResultList.new(model, @session, self)
          end
        end
      end

      class RackResultListComposite < HtmlGrid::DivComposite
        COMPONENTS = {
          [0, 0] => RackResultListInnerComposite
        }
        CSS_ID_MAP = {
          0 => 'rack_result_list_composite'
        }
        HTTP_HEADERS = {
          'type'    => 'text/html',
          'charset' => 'UTF-8'
        }
      end
    end
  end
end
