this.SortPages = function () {

// sorted pages, on mouseover make page top (z-index, store old index), on mouse out reset z-indes
    $('#sortable2').on('mouseenter mouseleave','.page_sort .preview_footer', function (event) {
        var page = $(this).parent();

        if (event.type == 'mouseenter') {
            page.data("old-z-index", page.css("z-index"));

            page.css("z-index", "10000");
            page.css("background", "darkgrey");
            $('.document_sort_frame .preview').each(function () {
                if ($(this)[0] != $(page)[0]) {
                    $(this).fadeTo(0, 0.3)
                }
            })


        } else {
            $('.document_sort_frame .preview').each(function () {
                if ($(this)[0] != $(page)[0]) {
                    $(this).fadeTo(0, 1)
                }
            })
            page.css("z-index", page.data("old-z-index"))
            page.css("background", "#d3d3d3")

        }
    });

    // sort page
    $("#sortable2").sortable({
        tolerance:'intersect',
        connectWith:'.document_page_index',
        update:function (event, ui) {
            align_pages();
        },
        remove:function (event, ui) {
            ui.item.removeClass('page_sort')
        },
        receive:function (event, ui) {
            ui.item.addClass('page_sort')
        }        ,
        stop:function (event, ui) {
            ui.item.find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
        }

    });

    // when a sortable page is removed, the destroy_page.js.erb sends updatesort to re-sort the pages
    $("#sortable2").bind('updatesort', function() {
        align_pages();
    });


    // submit button for upload
    $('#new_document').submit(function() {
        $.post($(this).attr('action'), $(this).serialize()+"&"+$('#sortable2').sortable('serialize'), null, "script");
        return false;
    });





}


function align_pages() {
    var items = $('.document_sort_frame .preview');
    items.fadeTo(0, 1);

    var page_size = 230;
    var sort_box_with = $('.document_sort_frame').innerWidth();
    var max_size = sort_box_with - page_size - 110;
    var n = items.length;
    var z = n + 1

    var margin = ((n * page_size) - max_size) / (n - 1);
    if (margin < 0) {
        margin = 0
    }

    var b_margin = false;
    items.each(function () {

        if (b_margin) {
            $(this).css("margin-left", -margin + 'px');
        }
        else {
            $(this).css("margin-left", '0px');
        }
        $(this).css("z-index", z);
        z = z - 1

        b_margin = true;
    });

}

//****************************************************************************************
this.IndexPages = function () {

// Index page: sortable list for Index Page, remove old class to be ready for the sortable page
    $("#sortable1").sortable({
        tolerance:'touch',
        connectWith:'.document_sort',
        receive:function (event, ui) {
            //        var sort_frame = ui.item.closest('div[class*="document_sort_frame"]');
            ui.item.removeAttr('style');
            ui.item.removeClass('page_sort').addClass('preview');
        }
        ,
        stop:function (event, ui) {
            ui.item.find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
        }


    });


};


//****************************************************************************************

$(document).ready(function () {
    SortPages();
    IndexPages();
});
