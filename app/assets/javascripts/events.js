$(function() {

    //set_cookie
    $("#application_name").change( function() {
        var application_name = $("#application_name").val();
        set_cookie( "selected_application_name", application_name, null );
        window.location.reload()
    });

    $("#environment_name").change( function() {
        var environment_name = $("#environment_name").val();
        set_cookie( "selected_environment_name", environment_name, null );
        window.location.reload()
    });
    $("#log_level").change( function() {
        var log_level = $("#log_level").val();
        set_cookie( "selected_log_level", log_level, null );
        window.location.reload();
    });

});