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

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Content-Type, Origin, Referer, User-Agent"
    headers["Access-Control-Max-Age"] = "3600"
  end

  def visits_preflight
    set_cors_headers
    logger.info "in sites#visits_preflight method"
    render :text => "", :content_type => "text/plain"
  end

  def visits
    set_cors_headers
    logger.info "in sites#visits method"
    if request.xhr?
      logger.info "Request is xhr"
      @site = Site.find_by_id(params[:id])

      # Create a new page if the visited URL is not yet in our list of tracked pages
      unless @site.nil?
        logger.info "existing site found!"
        @page = Page.find_by_url_and_site_id(params[:pageUrl], params[:id])
        logger.info "Looking for page... is it nil? #{@page.nil?}"
        
        if @page.nil?
          @page = Page.new
          @page.url = params[:pageUrl]
          @page.site_id = params[:id]
          logger.info "New page created? #{@page.valid?}"
        end

        seconds = params[:duration] * 0.001
        # Calculate new average duration
        @page.register_visit(seconds)
        @page.save

        @site.register_visit(seconds)
        @site.save

      else
        logger.info "SITE DOES NOT EXIST. Cancelling operations."
        #TODO: maybe add an alert of some sort?
      end
    else
      logger.info "Request NOT xhr"
      @site = Site.find_by_id(params[:id])

      # We only want to track visits for sites that we are currently tracking
      unless @site.nil?
        logger.info "existing site found!"
        @page = Page.find_by_url_and_site_id(params[:pageUrl], params[:id])
        logger.info "Looking for page... is it nil? #{@page.nil?}"
        
        # Create a new page if the visited URL is not yet in our list of tracked pages
        if @page.nil?
          @page = Page.new
          @page.url = params[:pageUrl]
          @page.site_id = params[:id]
          logger.info "New page created? #{@page.valid?}"
        end

        seconds = (params[:duration]).to_i * 0.001
        # Calculate new average duration
        @page.register_visit(seconds)
        @page.save

        @site.register_visit(seconds)
        @site.save

      else
        logger.info "SITE DOES NOT EXIST. Cancelling operations."
        #TODO: maybe add an alert of some sort?
      end
    end

    respond_to do |format|
      format.html { redirect_to(sites_path) } # redirect to sites page
      format.json { render json: @page }
    end
  end
end
