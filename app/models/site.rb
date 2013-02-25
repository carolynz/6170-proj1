class Site < ActiveRecord::Base
  attr_accessible :avgduration, :id, :name, :totalvisits

  has_many :pages, :inverse_of => :site
  validates :id,  :presence => true
  after_initialize :set_defaults

  # Sets some default avgduration, totalvisits, and name for a site, 
  # if they haven't been already specified upon creation
  def set_defaults
    self.avgduration ||= 0.0
    self.totalvisits ||= 0
    self.name ||= "unnamed site"
  end

  # Registers visits to a site by calculating new average duration on site
  # and incrementing the total visits count.
  #
  # Parameter duration is an integer representing
  # the duration of this site visit, in seconds
  def register_visit(duration)
    logger.info "We're in sites register_visit method!"
    #calculate new average duration
    self.avgduration = ((self.totalvisits)*(self.avgduration) + duration)/(self.totalvisits+1)
    #increment total visits
    self.totalvisits += 1
    logger.info "updated sites.avgduration: #{self.avgduration.inspect}"
    logger.info "updated sites.totalvisits: #{self.totalvisits.inspect}"
  end

end
