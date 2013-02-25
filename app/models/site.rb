class Site < ActiveRecord::Base
  attr_accessible :avgduration, :id, :name, :totalvisits

  has_many :pages, :inverse_of => :site

  before_create :set_defaults
  validates :id,  :presence => true

  private
  	def set_defaults
  		self.avgduration = 0.0
  		self.totalvisits = 0
  	end


end
