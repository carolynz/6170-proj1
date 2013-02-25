class Page < ActiveRecord::Base
  attr_accessible :avgduration, :totalvisits, :url, :site_id

  # I reference a site
  belongs_to :site , :inverse_of => :pages	# foreign key - site_id

  before_create :set_defaults
  validates :url,  :presence => true

  private
  	def set_defaults
  		self.avgduration = 0.0
  		self.totalvisits = 0
  	end


end
