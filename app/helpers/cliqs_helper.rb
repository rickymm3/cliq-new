module CliqsHelper

  def get_all_parent_cliqs(cliq)
    parents = []
    current = cliq
    while current.parent_cliq
      current = current.parent_cliq
      break if current == Cliq.find_by(name: "Cliq")
      parents << current
    end
    parents.reverse # To have the direct parent first
  end

  # Trail from just after `base` down to `target`.
  def cliq_chain(target)
    (target.respond_to?(:ancestors) ? target.ancestors : []) + [target]
  end

  # Trail from just after `base` down to `target`.
  def relative_trail_cliqs(base, target)
    chain = cliq_chain(target)
    idx   = chain.index(base)
    idx ? chain[(idx + 1)..-1] : chain
  end

  # Clickable relative trail, e.g. "Taylor Swift / Tours / Upcoming"
  def relative_trail_links(base, target, separator: " / ")
    cliqs = relative_trail_cliqs(base, target)
    return "" if cliqs.blank?

    safe_join(
      cliqs.map { |c|
        link_to c.name, cliq_path(c),
          data: { turbo_frame: "_top", turbo_action: "advance" },
          class: "post-path__link"
      },
      content_tag(:span, separator, class: "post-path__sep")
    )
  end
  
end
