// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function update_name_and_id(element,value){
  input_value = element.value;
  element.value = input_value.replace(/ #.*$/,'');
  $(element.id.replace(/_names$/,'_ids')).value +=
    input_value.replace(/^.*#/,'') + ', ';
}

var recurringBinds = function(event,data,status,xhr){
  var context = "";
  if($(this).attr("data-update")){
    context = '#' + $(this).attr("data-update");
    $(context).html(data);
  } else if(event == "rebind") {
    context = data;
  }
  var droppableHash = {
    hoverClass: "highlighted",
    greedy: true,
    drop: function(event,ui){
      //var href = document.location.href;
      var href = $('base').first().attr('id') + "/";
      if(href.charAt(href.length-1) == "#"){
        href = href.substring(0,href.length-1);
      }
      var url = href + "concepts/add_related/"+ui.draggable.attr('id')+"/";
      url += $(this).parents('tr').first().attr('db_id');
      var context = $(this).attr('data-context');
      if(context){
        url += "/" + context;
      }
      $.get(url);
    }
  };
  $("span.draggable").draggable();
  $("strong.droppable").droppable(droppableHash);
  $(context + " a[data-update], " + context + " form[data-update]").
    bind("ajax:success",recurringBinds);
  $(context + " a[data-update], " + context + " form[data-update]").
    attr("data-type", "html");
  return false;
};

jQuery(function($) {
  // create a convenient toggleLoading function
  $("#spinner").bind("ajaxStart", function(){
    $(this).show();
  }).bind("ajaxComplete", function(){
    $(this).fadeOut(1000);
  });
  $("error_box").bind("ajaxError", function(){
    $("#spinner").hide();
    $(this).show();
    $("#error_box").fadeOut(3000);
  });
  recurringBinds();
  $("a[data-update],form[data-update]").bind("ajax:success", recurringBinds);
  $("a[data-update],form[data-update]").attr("data-type", "html");
  $("img.close_button").live("click", function(){
    $(this).parents(".relations").first().parent().html("");
    return false;
  });
});
