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

    var has_scrolled = false,
        is_resizing  = false,
        marker       = $("#get-more-items"),
        marker_top   = marker.offset().top,
        log_console  = $("#log-console"),
        target_url   = log_console.attr("data-url");

    $( window ).scroll( function() { has_scrolled = true; });

    function load_more_events() {
        var last_event = log_console.find(".event").filter(":last");

        is_resizing = true;

        $.ajax({
            url: target_url,
            data: { last_id: last_event.attr("object-id") },
            success: function( data, textStatus, jqXHR ) {
                marker.before( data );
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

    setInterval( function() {
        if ( has_scrolled && !is_resizing ) {
            if ( ($(window).scrollTop() + $(window).height()) >= marker_top ) {
                load_more_events();                
            }

            has_scrolled = false;
        }
    }, 500);

    load_more_events();

});