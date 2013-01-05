$(function() {
    var candidate_list = $("#candidate_user_list"), 
        authorized_list = $("#authorized_user_list"), 
        url = candidate_list.attr("user-list-url"),
        timer = null,
        user_field = $("#user_auto_complete_field");

    function synchronizeLists() {
        candidate_list.find("li").each( function() {
            var $this = $(this), id = $this.attr("object-id");

            if ( authorized_list.find("*[object-id='" + id + "']").length != 0 ) {
                $this.addClass("disabled");
            } else {
                $this.removeClass("disabled");
            }
        });
    }

    function addCandidate( id, name, email ) {
        var item = $("<li class='well'></li>").attr("object-id", id);

        item.append("<b>" + name + "</b> ");
        item.append("<small>" + email + "</small> ");
        item.append("<i class='icon-forward'></i>");

        candidate_list.append( item );
    }

    function fetchCandidates() {
        var term = user_field.val();

        $.ajax({
            url: url,
            data: { term: term },
            success: function( data, textStatus, jqXHR ) {
                candidate_list.empty();
                $(data).each( function() {
                    addCandidate( this["id"], this["name"], this["email"] );
                });
                synchronizeLists();
            }
        });
    }

    candidate_list.click( function( event ) {
        var clickTarget = $(event.target);

        if ( clickTarget.prop("tagName") === "I" ) {
            var candidate = clickTarget.parents("li").first(),
                authorized = $("<li class='well'></li>"),
                objectId = candidate.attr("object-id");

            authorized.prepend("<i class='icon-remove'></i> ");
            authorized.append("<b>" + candidate.find("b").first().text() + "</b> ");
            authorized.append("<small>" + candidate.find("small").text() + "</small>");
            authorized.append("<input type='hidden' name='users[]' value='" + objectId + "' />");

            authorized.attr("object-id", objectId);

            authorized_list.append( authorized );

            synchronizeLists();
        }
    });

    authorized_list.click( function( event ) {
        var clickTarget = $(event.target);

        if ( clickTarget.prop("tagName") === "I" ) {
            clickTarget.parents("li").first().remove();
            synchronizeLists();
        }
    });

    user_field.keyup( function( event ) {
        var term = $(this).val(), 
            key = event.keyCode,
            ignoreKeys = [ 91, 55, 18, 55, 17, 55, 16, 55, 20, 37, 38, 39, 40 ];

        if ( $.inArray( key, ignoreKeys ) == -1 ) {
            if ( timer != null ) { clearTimeout( timer ); }

            timer = setTimeout( fetchCandidates, 500);

        }
    });

    if ( user_field.val() != null && user_field.val().length != 0 ) {
        fetchCandidates();
    }

});