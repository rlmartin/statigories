# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user
    @controller.send(:current_user)
  end

  def current_user_stub
    @controller.send(:current_user_stub)
  end

  def is_mine
    @controller.send(:is_mine)
  end

  def my_user_id
    @controller.send(:my_user_id)
  end

  def my_username
    @controller.send(:my_username)
  end

  # If passed a Symbol in the 'text' parameter, this will automatically translate the symbol.
  def prep_rjs(text)
    strTemp = text.to_s
    if text.is_a?(Symbol): strTemp = t(text) end
    if ENV['RAILS_ENV'] == 'test'
      # In the test environment, wrap the text in a <span> for testing purposes (assert_select_rjs has trouble matching straight text nodes).
      '<span>' + strTemp + '</span>'
    else
      strTemp
    end
  end

  def finish_rjs(page)
    if @success
      page[:error_msg].replace_html prep_rjs('')
      page[:error_msg].hide
      page[:notice_msg].replace_html prep_rjs(flash[:notice])
      page[:notice_msg].show
    else
      page[:notice_msg].replace_html prep_rjs('')
      page[:notice_msg].hide
      page[:error_msg].replace_html prep_rjs(flash[:error])
      page[:error_msg].show
    end
  end

end
