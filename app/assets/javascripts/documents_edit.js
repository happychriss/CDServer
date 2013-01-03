// Sorting the order of docs by updating the position hidden field
this.UpdateDocumentPages = function () {

    $('.doc_sort_list').sortable({
        dropOnEmpty: false,
        items: 'li',
        opacity: 0.4,
        scroll: true,
        update: function() {
            $.ajax({
                type: 'post',
                data: $('.doc_sort_list').sortable('serialize') ,
                dataType: 'script',
                complete: function(request) {
                    $('#docs').effect('highlight');
                },

                url: '/sort_pages'
            })
        }

    });
};

$(document).ready(function () {
    UpdateDocumentPages();
//    SimplePollStatus();

});




