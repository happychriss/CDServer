this.SortPreview = function(){

   var controller = $('#controller_div').val();

   $("div.page").draggable();


   $("div.preview").droppable({
        		drop: function( event, ui ) {

                var drop_id=this.id;
                var drag_id=ui.draggable.attr("id");
  //              var count_id=$("a",this).attr("id");

                var parameters = 'drop_id='+drop_id+"&"+'drag_id='+drag_id //+"&"+'count_id='+count_id;
                $.post(controller, parameters);

			}

    });

};

$(document).ready(function(){
	SortPreview();
});

