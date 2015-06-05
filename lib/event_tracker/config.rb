module EventTracker
  class Config
    attr_accessor :segment_io_key
    attr_accessor :disabled
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield self.config
  end

  def self.disabled?
    self.config.disabled == true
  end
end