require 'htmlgrid/divform'
require 'htmlgrid/divlist'
require 'view/_partial/form'
require 'view/_partial/select'
require 'view/_partial/image'

module DaVaz::View
  class ShowAllTagsLink < HtmlGrid::Div
    CSS_ID = 'all_tags_link'

    def init
      super
      link = HtmlGrid::Link.new(:show_tags, @model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        return toggleInnerHTML(
          'all_tags_link'
        , '#{@lookandfeel.event_url(:gallery, :ajax_all_tags)}'
        );
      EOS
      @value = link
    end
  end

  class ShowAllTagsList < HtmlGrid::DivList
    COMPONENTS = {
      [0, 0] => :tag,
      [1, 0] => 'pipe_divider'
    }

    def tag(model)
      link = HtmlGrid::Link.new(model.name, model, @session, self)
      link.value = model.name
      link.href  = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        var values    = document.artobjectform.tags_to_s.value.split(',')
          , has_value = false
          ;
        for (idx = 0; idx < values.length; idx++) {
          if (values[idx] == '#{model.name}') {
            has_value = true;
          }
        }
        if (!has_value) {
          values[values.length] = '#{model.name}';
        }
        document.artobjectform.tags_to_s.value = values.join(',');
      EOS
      link
    end
  end

  class ShowAllTags < HtmlGrid::DivComposite
    COMPONENTS = {
      [0, 0] => ShowAllTagsList,
      [0, 1] => :close,
    }
    CSS_ID_MAP = {
      0 => 'all_tags',
      1 => 'close_all_tags',
    }

    def close(model)
      link = HtmlGrid::Link.new(:close, model, @session, self)
      link.href = 'javascript:void(0);'
      link.set_attribute('onclick', <<~EOS.gsub(/(^\s*)|\n/, ''))
        toggleInnerHTML(
          'all_tags_link',
          '#{@lookandfeel.event_url(:gallery, :ajax_all_tags_link)}'
        );
      EOS
      link
    end
  end
end
