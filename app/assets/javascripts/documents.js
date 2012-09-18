
// Sorting the order of docs by updating the position hidden field
this.SortDetail = function () {

    $('ul.sort').sortable({
        dropOnEmpty:false,
        items:'li',
        opacity:0.4,
        scroll:true,
        update:function () {
            $('.position').each(function (index) {
                $(this).val(index);
            });
        }

    });
};

// Creating a Delete Link and update an item with destroy value
this.DeleteLink = function () {
    $('.clicklink').click(function() {
//        if (confirm("Are you sure?")) {}
            $(this).find(':input').attr('checked', true);
            $(this).parents('.preview').hide()

        return (false);
    });
};

$(document).ready(function () {
    SortDetail();
    DeleteLink();
});


