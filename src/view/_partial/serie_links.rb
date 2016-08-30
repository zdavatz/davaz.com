require 'htmlgrid/spanlist'
require 'htmlgrid/divlist'
require 'htmlgrid/link'

module DaVaz::View
  module SerieLinks
    def serie_link(model, replace_id)
      link = HtmlGrid::Link.new(:serie_link, model, @session, self)
      link.href      = 'javascript:void(0);'
      link.value     = model.name.gsub(' ', '&nbsp;')
      link.css_class = 'serie-link'
      link.css_id    = model.serie_id
      url = @lookandfeel.event_url(:gallery, :ajax_rack, [
        [:serie_id, model.serie_id]
      ])
      link.set_attribute('onclick', <<~EOS)
        return toggleShow('show', '#{url}', null,
          '#{replace_id}', '#{model.serie_id}');
      EOS
      link
    end

    def series(model, target)
      res = []
      model.series.each.with_index(1) { |serie, idx|
        next if serie.name.to_s.strip.empty?
        res.push(', ') unless res.empty?
        link = serie_link(serie, target)
        link.css_class << ' even' if idx.even?
        res.push(link)
      }
      res
    end
  end
end
