class SystemController < ApplicationController

    def status
        status_object = {}

        status_object["app_state"] = "up"
        status_object["app_home_url"] = login_url

        status_object["api_methods"] = {}

        status_object["api_methods"]["publish_event"] = api_event_publisher_url

        render :json => status_object
    end

end
