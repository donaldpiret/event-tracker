class Hash
  def merge_if(condition, target = nil)
    condition ? self.merge(target ? target : condition) : self
  end

  def deep_merge_if(condition, target)
    condition ? self.deep_merge(target) : self
  end
end