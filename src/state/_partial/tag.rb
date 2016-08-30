require 'sbsm/state'
require 'state/predefine'
require 'view/_partial/tag'

module DaVaz::State
  # @api admin
  # @api ajax
  # @note responds to:
  #   /de/gallery/ajax_all_tags
  class AdminAjaxAllTags < SBSM::State
    VIEW     = DaVaz::View::ShowAllTags
    VOLATILE = true

    def init
      @model = @session.app.load_tags
    end
  end

  # @api admin
  # @api ajax
  class AdminAjaxAllTagsLink < SBSM::State
    VIEW     = DaVaz::View::ShowAllTagsLink
    VOLATILE = true

    def init
      @model = []
    end
  end
end
