class GeneralPageController < ApplicationController
  def index
    @page[:title] = "Home"
  end

  def page_not_found
    @page[:title] = "Page Not Found"
    obj = { :error => @page[:title] }
    respond_to do | format |
      format.html
      format.xml { render :xml => obj.to_xml }
      format.json { render :json => obj.to_json }
      format.js
    end
  end
end
