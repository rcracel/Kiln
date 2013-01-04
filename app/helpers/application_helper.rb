module ApplicationHelper

    def has_role( role, user = nil, &block )
        user = current_user if user.nil?

        if user && user.roles.include?( role )
            yield( block )
        end
    end

end
