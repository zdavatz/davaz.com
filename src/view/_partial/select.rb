require 'htmlgrid/composite'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module DaVaz
  module View
    class DynSelect < HtmlGrid::AbstractSelect

      def init
        super
        url = @lookandfeel.event_url(:gallery, :ajax_check_removal_status, [
          [:artobject_id, @model.artobject_id],
          [:select_name,  @name],
          [:selected_id,  nil]
        ])
        selected_id = ''
        #selected_id = @model.selected ? @model.selected.send(@name.intern) : ''
        set_attribute('onchange', <<~EOS)
          checkRemovalStatus(this.value, '#{url}');
        EOS
        self.onload = "checkRemovalStatus('#{selected_id}', '#{url}');"
        set_attribute('id', @name + '_select')
      end

      private

      def selection(context)
        selection = @model.selection.collect { |value|
          context.option(
            'value'    => value.sid,
            'selected' => value == @model.selected
          ) { value.name }
        }
        # title
        selection.unshift(context.option('value' => '') {
          @lookandfeel.lookup(:please_select)
        })
      end
    end

    # @api ajax
    class AjaxDynSelect < DynSelect
      include HtmlGrid::ErrorMessage

      def to_html(context)
        html  = super
        error = @session.error(@name)
        if error
          html << context.br << error_text(error).to_html(context)
        end
        html
      end
    end
  end
end
