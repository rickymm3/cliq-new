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
  
end
