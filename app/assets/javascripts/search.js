// enable drag and drop for the search pages

this.DropPages = function () {
    $(".search_draggable").draggable({
        revert: 'invalid',
        zIndex: 2000
    });

    $(".search_droppable").droppable({
        accept: ".search_draggable",
        drop: function( event, ui ) {

            var drop_id=this.id;
            var drag_id=ui.draggable.attr("id");

            var parameters = 'drop_id='+drop_id+"&"+'drag_id='+drag_id;
            $.post("add_page", parameters);
        }
    });

};

$(document).ready(function () {
    DropPages();

});

