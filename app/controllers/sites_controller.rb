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

  # GET /sites/1/visits
  # GET /sites/1/visits.json
  def visits
    if request.xhr?
      @site = Site.find_by_id(params[:id])

      #if the site doesn't exist, create a new site instance with 0 visits
      if @site.nil? 
        @site = Site.new
        @site.id = (params[:id])
        @site.name = 'unnamed site'
      end

      #parse the query string parameters
      qstring = CGI::unescape(request.query_string)
      page_params = CGI::parse(qstring)

      #convert duration from milliseconds to seconds
      seconds = page_params[:duration] * 0.001
      

      #if the page doesn't exist on our analytics tracking site, create a new page instance with 0 visits
      @page = Page.find(page_params[:pageUrl])
      if @page.nil?
        @page = Page.new
        @page.url = (page_params[:pageUrl])
        @page.site_id = @site.id
      end

      
      #call the page's "visit" method to update its average duration and total visits
      @page.visit(page_params[:pageUrl], seconds)

      #calculate new average duration
      @site.avgduration = ((@site.totalvisits*@site.avgduration) + seconds)/(@site.totalvisits+1)
      #increment visits
      @site.totalvisits += 1

      @site.save
      
      respond_to do |format|
        format.html # visits.html.erb
        format.json { render json: @site }
      end
    end
  end
end
