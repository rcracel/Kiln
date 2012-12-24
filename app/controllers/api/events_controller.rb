class Api::EventsController < ApplicationController

    skip_before_filter :authorize

    def publish
        events      = params[:events]
        api_key     = params[:api_key]

        application = Application.first( :api_key => api_key )

        if not application.nil?
            events.each do |event|

                log_event = Event.new( event )

                log_event.timestamp  = DateTime.strptime( event[:timestamp], "%m/%d/%Y %H:%M:%S %z" ).to_time unless event[:timestamp].nil?

                log_event.ip_address = (request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip)

                log_event.application = application

                log_event.save()

            end

            render :status => :ok, :json => { :result => "stored #{events.length} events" }
        else
            render :status => :unauthorized, :json => { error: "missing or invalid api key" }
        end
    end

    def list

    end

end
