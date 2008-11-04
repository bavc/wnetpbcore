class AssetsController < ApplicationController
  def index
    alternate "application/atom+xml", :format => "atom", :q => params[:q]
    @query = params[:q]
    @page_title = @query ? "Search for #{@query}" : "Assets"
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == ""
    @search_object = @query ? 
      AssetTerms.search(@query, {:match_mode => :extended, :include => {:asset => :titles}}.merge(pageopts)) :
      Asset.paginate(:all, {:order => 'updated_at DESC', :include => :titles}.merge(pageopts))
    @assets = @query ? @search_object.map{|at| at.asset} : @search_object
    
    respond_to do |format|
      format.html
      format.atom
    end
  end
  
  def destroy
    asset = Asset.find(params[:id], :include => :titles)
    titles = asset.title
    asset.destroy
    @destroyed_id = params[:id]
    
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{titles}</strong> has been deleted from the database."
        redirect_to :action => 'index'
      end
      format.js
    end
  end
  
  def show
    alternate "application/xml", :format => "xml"
    if params[:id] =~ /^[\d]+$/
      @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    else
      @asset = Asset.find_by_uuid(params[:id].gsub(/^urn:uuid:/, ''), :include => Asset::ALL_INCLUDES)
    end
    if @asset
      @page_title = "View Asset"
      respond_to do |format|
        format.html
        format.xml { render :xml => @asset.to_xml }
      end
    else
      flash[:error] = "Invalid Asset ID specified"
      redirect_to :action => 'index'
    end
  end
  
  def new
    @asset = Asset.new
    @asset.identifiers.build
    @asset.titles.build
    @page_title = "New Asset"
  end
  
  def edit
    @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    @page_title = "Edit Asset"
  end
  
  def create
    @asset = Asset.new(params[:asset])
    if @asset.save
      flash[:message] = "Successfully created new Asset."
      redirect_to :action => 'index'
    else
      @page_title = "New Asset"
      render :action => 'new'
    end
  end
  
  def update
    @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    params[:asset] ||= {}
    params[:asset][:identifier_attributes] ||= {}
    params[:asset][:title_attributes] ||= {}
    params[:asset][:subject_attributes] ||= {}
    params[:asset][:description_attributes] ||= {}
    params[:asset][:genre_attributes] ||= {}
    params[:asset][:relation_attributes] ||= {}
    params[:asset][:coverage_attributes] ||= {}
    params[:asset][:audience_rating_ids] ||= []
    params[:asset][:audience_level_ids] ||= []
    if @asset.update_attributes(params[:asset])
      flash[:message] = "Successfully updated your Asset."
      redirect_to :action => 'index'
    else
      @page_title = 'Edit Asset'
      render :action => 'edit'
    end
  end

  # give opensearch descriptor document
  def opensearch
    respond_to do |format|
      format.xml
    end
  end
end
