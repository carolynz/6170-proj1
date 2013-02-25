class Page < ActiveRecord::Base
  attr_accessible :avgduration, :totalvisits, :url, :site_id

  belongs_to :site , :inverse_of => :pages	# foreign key - site_id
  validates :url,  :presence => true
  validates :site_id, :presence => true
  after_initialize :set_defaults

  # Sets the default values for a page's avgduration and totalvisits,
  # if they haven't been already specified upon creation.
  def set_defaults
    self.avgduration ||= 0.0
    self.totalvisits ||= 0
  end

  # Registers visits to a page by
  # calculating new average duration on a page
  # and incrementing the total visits count.
  #
  # Parameter duration is an integer representing
  # the duration of this site visit, in seconds.
  def register_visit(duration)
    logger.info "We're in pages register_visit method!"
    #calculate new average duration
    self.avgduration = ((self.totalvisits)*(self.avgduration) + duration)/(self.totalvisits+1)
    #increment total visits
    self.totalvisits += 1
    logger.info "updated page.avgduration: #{self.avgduration.inspect}"
    logger.info "updated page.totalvisits: #{self.totalvisits.inspect}"
  end

end
