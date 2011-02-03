class LogEntriesController < ApplicationController
  include ArrayLib
	before_filter [:load_user_from_param, :load_permissions_for_user, :load_log_entry_from_param]
  before_filter :check_authorization_edit, :only => [:add_tags, :edit_tags]

  def create
  end

  def edit_label
    unless error_page_on_fail @log_entry != nil, :msg_log_entry_not_found
      @log_entry.label = params[:label]
      @log_entry.save
      flash[:notice] = 'Saved.'
    end
    render :show unless performed?
  end

  def show
    error_page_on_fail @log_entry != nil, :msg_log_entry_not_found
    error_page_on_fail @log_entry.access_level == LogEntry::PUBLIC, :msg_log_entry_private unless performed?
    render :show unless performed?
  end

  protected
  def load_log_entry_from_param
    if @user == nil: redirect_to user_path(params[:username]) end
    @log_entry = nil
    unless @user == nil
      @log_entry = @user.log_entries.find_by_index(params[:index])
      unless @log_entry == nil: @page[:title] = t(:title_log_entry, :index => @log_entry.index, :tags => @log_entry.tag_list.to_s.titleize) + ' : ' + @page[:title] end
    end
  end
end
