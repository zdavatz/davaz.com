require 'state/predefine'
require 'state/public/global'
require 'view/public/articles'
require 'view/public/articles'
require 'view/public/article'

module DaVaz::State
  module Public
    class AjaxArticle < SBSM::State
      VIEW     = DaVaz::View::Public::ArticleComposite
      VOLATILE = true

      def init
        article_id = @session.user_input(:artobject_id)
        @model = @session.load_article(article_id)
      end
    end

    class Articles < Global
      VIEW = DaVaz::View::Public::Articles

      def init
        @model = @session.load_articles
      end
    end

    class AdminArticles < Articles
      VIEW = DaVaz::View::Public::AdminArticles
    end
  end
end
