class LogEntryItemsController < ApplicationController
  def input
    @log_entry_item = LogEntryItem.find_by_id(params[:id])
    unless @log_entry_item
      @log_entry_item = LogEntryItem.new
      @log_entry_item.tag_list = t(:default_log_entry_item_label)
    end
    @tag_name = params[:tag_name]
    @can_edit = true
  end
end
