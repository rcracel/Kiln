class Api::EventsController < ApplicationController

    def publish
        events = params[:events]

        events.each do |event|

            log_event = Event.new( event )

            log_event.timestamp  = DateTime.strptime( event[:timestamp], "%m/%d/%Y %H:%M:%S %z" ).to_time unless event[:timestamp].nil?

            log_event.ip_address = (request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip)

            log_event.save()

        end

        render :json => "Yes"
    end

end
