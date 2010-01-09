# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def is_mine
    @controller.send(:is_mine)
  end

  def my_user_id
    @controller.send(:my_user_id)
  end

  # If passed a Symbol in the 'text' parameter, this will automatically translate the symbol.
  def prep_rjs(text)
    strTemp = text
    if text.is_a?(Symbol): strTemp = t(text) end
    if ENV['RAILS_ENV'] == 'test'
      # In the test environment, wrap the text in a <span> for testing purposes (assert_select_rjs has trouble matching straight text nodes).
      '<span>' + strTemp + '</span>'
    else
      strTemp
    end
  end

end
