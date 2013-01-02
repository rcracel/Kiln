$(function() {

    //set_cookie
    $("#event-filter #visualization_format").change( function() {
        var visualization_format = $(this).val();
        set_cookie( "selected_format", visualization_format, null );
        window.location.reload();        
    });

    $("#event-filter #application_name").change( function() {
        var application_name = $(this).val();
        set_cookie( "selected_application_id", application_name, null );
        window.location.reload();
    });

    $("#event-filter #module_name").change( function() {
        var module_name = $(this).val();
        set_cookie( "selected_module_name", module_name, null );
        window.location.reload();
    });

    $("#event-filter #environment_name").change( function() {
        var environment_name = $("#environment_name").val();
        set_cookie( "selected_environment_name", environment_name, null );
        window.location.reload();
    });

    $("#event-filter #log_level").change( function() {
        var log_level = $(this).val();
        set_cookie( "selected_log_level", log_level, null );
        window.location.reload();
    });

    $('#event-filter #dp1').datepicker().on('changeDate', function( ev ) {
        set_cookie( "selected_date_from", $("#date_from").val(), null );
    });

    $("#event-filter #btn_apply").click( function() {
        window.location.reload();
    });

    $("#event-filter #btn_reset").click( function() {
        set_cookie( "selected_application_id", "", null );
        set_cookie( "selected_module_name", "", null );
        set_cookie( "selected_environment_name", "", null );
        set_cookie( "selected_log_level", "", null );
        set_cookie( "selected_date_from", "", null );
        window.location.reload();
    });

    var has_scrolled      = false,
        is_resizing       = false,
        marker            = $("#get-more-items"),
        marker_top        = marker.offset().top,
        log_console       = $("#log-console"),
        tail_target_url   = log_console.attr("data-tail-url"),
        head_target_url   = log_console.attr("data-head-url"),
        tail_timer        = null,
        head_timer        = null,
        stacktrace_dialog = $("#stacktrace-dialog");

    $( window ).scroll( function() { has_scrolled = true; });

    function process_events( container ) {
        $(container).find(".event").each( function() {
            var event = $(this);

            event.find("*[data-trigger='stacktrace']").click( function() {
                var url = $(this).attr("data-url");

                $('body').modalmanager('loading');

                // stacktrace_dialog.find(".modal-body").empty();

                stacktrace_dialog.find(".modal-body").load(url, '', function(){
                    stacktrace_dialog.modal();
                });

            });
        });
    }

    function load_tail_events() {
        var last_event = log_console.find(".event").filter(":last");

        is_resizing = true;

        $.ajax({
            url: tail_target_url,
            data: { last_id: last_event.attr("object-id") },
            success: function( data, textStatus, jqXHR ) {
                if ( data == null || data.trim().length == 0 ) {
                    marker.remove();
                    clearInterval( tail_timer );
                } else {
                    var container = $("<span></span>");

                    container.append( data );

                    marker.before( container );

                    process_events( container );
                }
            },
            error: function( jqXHR, textStatus, errorThrown ) {
                console.info( errorThrown );
            },
            complete: function( jqXHR, textStatus ) {
                marker_top   = marker.offset().top;
                is_resizing  = false;
                has_scrolled = false;
            }
        });
    }

    tail_timer = setInterval( function() {
        if ( has_scrolled && !is_resizing ) {
            var w = $(window);

            if ( ( w.scrollTop() + ( w.height() * 2 ) ) >= marker_top ) {
                load_tail_events();                
            }

            has_scrolled = false;
        }
    }, 250);

    function poll_new_events( delay ) {
        var first_event = log_console.find(".event").filter(":first"), wait_time = delay;
        $.ajax({
            url: head_target_url,
            data: { first_id: first_event.attr("object-id") },
            success: function( data, textStatus, jqXHR ) {
                if ( data == null || data.trim().length == 0 ) {
                    //- Nothing to report
                } else {
                    var container = $("<span></span>");

                    container.append( data );

                    log_console.prepend( container );

                    process_events( container );
                }
            },
            complete: function( jqXHR, textStatus ) {
                setTimeout( function() { poll_new_events( wait_time ); }, wait_time );
            }
        });
    }

    load_tail_events();

    //- Although this is a good idea, I am currently concerned with performance on the server side
    poll_new_events( 5000 );

});