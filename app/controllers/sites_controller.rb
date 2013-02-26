require 'cgi'

class SitesController < ApplicationController
  # GET /sites
  # GET /sites.json
  def index
    @sites = Site.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render json: @site, status: :created, location: @site }
      else
        format.html { render action: "new" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    @site = Site.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :no_content }
    end
  end

  # Called at beginning of visits_preflight and visits
  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Content-Type, Origin, Referer, User-Agent"
    headers["Access-Control-Max-Age"] = "3600"
  end

  # Responds to preflight OPTIONS request
  def visits_preflight
    set_cors_headers
    render :text => "", :content_type => "text/plain"
  end

  # Called every time a request is made to sites/:id/visits
  def visits
    set_cors_headers

    @site = Site.find_by_id(params[:id])

    unless @site.nil?
      # Only do the following if the site with ID params[:id] is in our list of tracked sites
      logger.info "Existing site found!"
      @page = Page.find_by_url_and_site_id(params[:pageUrl], params[:id])
      
      if @page.nil?
        # Create a new page if the visited URL is not yet in our list of tracked pages
        logger.info "Page with given URL and site ID not found. Creating new Page object to track visits."
        @page = Page.new
        @page.url = params[:pageUrl]
        @page.site_id = params[:id]
        logger.info "New page created? #{@page.valid?}"
      end

      # Convert params[:duration] from milliseconds to seconds.
      # params[:duration] is in milliseconds. register_visit methods only take input in seconds.
      seconds = (params[:duration]).to_i * 0.001
      # Let the page register the visit
      @page.register_visit(seconds)
      @page.save
      # Let the site register the visit
      @site.register_visit(seconds)
      @site.save

    else
      # Failure path: request's site_id is not an ID of a site we are tracking
      logger.info "Site with given ID not found. Visit not registered."
    end

    respond_to do |format|
      format.html { redirect_to(sites_path) } # redirect to sites page
      format.json { render json: @page }
    end
  end
end
