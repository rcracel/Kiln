module ApplicationHelper

    def has_role( role, &block )
        if current_user && current_user.roles.include?( role )
            yield( block )
        end
    end

end
