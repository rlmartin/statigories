require 'test_helper'

class UsersControllerTest < ActionController::IntegrationTest
  
  def test_check_user_availability
    get '/signup'
    assert_response :success
    xhr :get, '/user', :username => users(:ryan).username + 'xx'
#    assert_nil assigns(:user)
    assert_select_rjs :replace, "availability_results"
  end

end

