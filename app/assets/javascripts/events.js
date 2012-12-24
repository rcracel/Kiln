$(function() {

    //set_cookie
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

});