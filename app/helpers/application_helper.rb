# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user
    controller.send(:current_user)
  end

  def current_user_stub
    controller.send(:current_user_stub)
  end

  def is_mine
    controller.send(:is_mine)
  end

  def my_user_id
    controller.send(:my_user_id)
  end

  def my_username
    controller.send(:my_username)
  end

  # If passed a Symbol in the 'text' parameter, this will automatically translate the symbol.
  def prep_jquery(text)
    strTemp = text.to_s
    strTemp = t(text) if text.is_a?(Symbol)
    escape_javascript(strTemp)
  end

  def prep_rjs(text)
    strTemp = text.to_s
    strTemp = t(text) if text.is_a?(Symbol)
    if Rails.env.test?
      # In the test environment, wrap the text in a <span> for testing purposes (assert_select_rjs has trouble matching straight text nodes).
      escape_javascript('<span>' + strTemp + '</span>')
    else
      escape_javascript(strTemp)
    end
  end

  def show_messages_js
    if @success
      "$('#error_msg').html('#{prep_jquery('')}').hide();
      $('#notice_msg').html('#{prep_jquery(flash[:notice])}').show();".html_safe
    else
      "$('#notice_msg').html('#{prep_jquery('')}').hide();
      $('#error_msg').html('#{prep_jquery(flash[:error])}').show();".html_safe
    end
  end

end
