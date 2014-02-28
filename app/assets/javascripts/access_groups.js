$(document).ready(function(){
    $("#access_group_add_user").on('click', function(event) {
        var user_email, user_id;
        user_email = $("#other_users_select option:selected").text();
        user_id = $("#other_users_select option:selected").val();

        var selector = "li#user_" + user_id;

        if (!$(selector).length && isNotPrimary() && user_id != "") {
            addUser(user_id, user_email, selector);
        }

       return event.preventDefault();
    });

    $("#primary_user_select").on('change', removePrimaryInList);

    $(".delete_user").live('click', function(){
        $(this).parent().remove();
        return false;
    });

    function isNotPrimary() {
        var primary_user = $("#primary_user_select option:selected").val();
        var current_users = $("#other_users_select option:selected").val();
        return primary_user != current_users;
    }

    function removePrimaryInList() {
        var primary_user = $("#primary_user_select option:selected").val();
        var current_users = [];
        $("#users_list").find('li').each(function() {
            current_users.push($(this).attr('id'));
        });

        if ($.inArray("user_" + primary_user, current_users) >= 0) {
            var user_id = "#user_" + primary_user;
            $(user_id).remove();
        }
    }

    function addUser(user_id, user_email, selector) {
        var id = "user_" + user_id;

        $('<li>').attr("id", id).appendTo("ul#users_list");
        $('<input type=hidden>').attr({name: 'user_ids[]', value: user_id}).appendTo(selector);
        $(selector).append('<span>' + user_email + '</span>');
        $(selector).append("<a href='#' class='delete_user delete_link'> Delete</a>");
        $('<span>').attr({name: 'remove_user', "class": 'remove_button'}).appendTo(selector);
    }
});
