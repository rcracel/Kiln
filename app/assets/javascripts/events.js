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

    $('#dp1').datepicker().on('changeDate', function( ev ) {        
    });

    $("#btn_apply").click( function() {
        set_cookie( "selected_date_from", $("#date_from").val(), null );
        window.location.reload();
    });

    $("#btn_reset").click( function() {
        set_cookie( "selected_application_name", "", null );
        set_cookie( "selected_environment_name", "", null );
        set_cookie( "selected_log_level", "", null );
        set_cookie( "selected_date_from", "", null );
        window.location.reload();
    });

});