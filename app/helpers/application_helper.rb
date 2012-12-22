module ApplicationHelper

    def apply_timezone( date )
        tz_date = date

        if ( current_user.timezone )
            tz = ActiveSupport::TimeZone.new current_user.timezone
            tz_date = tz_date.in_time_zone( tz )
        end

        return tz_date
    end


end
