require "test_helper"

class Api::V1::MaintenanceRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_maintenance_records_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_maintenance_records_show_url
    assert_response :success
  end

  test "should get create" do
    get api_v1_maintenance_records_create_url
    assert_response :success
  end

  test "should get update" do
    get api_v1_maintenance_records_update_url
    assert_response :success
  end

  test "should get destroy" do
    get api_v1_maintenance_records_destroy_url
    assert_response :success
  end
end
