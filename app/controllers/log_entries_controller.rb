class LogEntriesController < ApplicationController
  include ArrayLib
	before_filter :load_user_from_param, :load_permissions_for_user, :load_log_entry_from_param
  before_filter :load_user_from_param_or_current_user, :only => :new
  before_filter :check_authorization_edit, :only => [:edit, :new, :quick_add, :quick_add_form]
#  before_filter :check_authorization_view, :only => [:show]

  def edit
    @log_entry = @user.log_entries.new if @log_entry == nil
    @log_entry.label = params[:label]
    @log_entry.save
    LogEntryItem.update_all('deleted = true', "log_entry_id = #{@log_entry.id}")
    if params[:item]
      params[:item].each_index { | i |
        p_item = params[:item][i]
        item = nil
        item = @log_entry.items.find_by_id(p_item['id']) if p_item['id']
        if item
          item.value = p_item['value']
          item.tag_list = p_item['tags']
          item.display_order = (i + 1)
          item.deleted = false
          item.save
        else
          item = @log_entry.items.new(:value => p_item['value'], :display_order => (i + 1))
          item.tag_list = p_item['tags']
          item.save
        end
      }
    end
    flash[:notice] = t(:msg_log_entry_saved)
    redirect_to user_log_path(:index => @log_entry.index)
  end

  def new
    @log_entry = LogEntry.new
    @log_entry.label = t(:default_log_entry_label)
    render :show
  end

  def quick_add
    # Simply show the form if no entry is passed in.
    unless (params[:entry] == nil or params[:entry].strip == '')
      objLog = StringLib.parse_log(params[:entry])
      objLog.each_key { |strKey|
        @log_entry = @user.log_entries.create(:label => String.new(strKey))
        objLog[strKey].each {|objItem|
          item = @log_entry.items.create(:value => objItem[:value])
          if objItem[:label].to_s.strip != ''
            item.tag_list = objItem[:label]
            item.save
          end
        }
      }
      redirect_to user_log_path(:index => @log_entry.index)
    end
  end

  def show
    error_page_on_fail @log_entry != nil, :msg_log_entry_not_found
    error_page_on_fail @log_entry.access_level == LogEntry::PUBLIC, :msg_log_entry_private unless performed?
    render :show unless performed?
  end

  def show_all
    limit = params[:num].to_i
    limit = 10 if limit <= 0
    start = params[:start].to_i
    start = 1 if start <= 0
    @logs = @user.log_entries.order('created_at DESC').limit(limit).offset(start - 1)
  end

  protected
  def load_log_entry_from_param
    redirect_to user_path(params[:username]) if @user == nil
    @log_entry = nil
    unless @user == nil
      @log_entry = @user.log_entries.find_by_index(params[:index])
      @page[:title] = t(:title_log_entry, :index => @log_entry.index, :tags => @log_entry.tag_list.to_s.titleize) + ' : ' + @page[:title] unless @log_entry == nil
    end
  end
end
