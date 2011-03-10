(function() {
  Danbooru.Unapproval = {};
  
  Danbooru.Unapproval.initialize_all = function() {
    this.initialize_unapprove();
    this.hide_or_show_unapprove_link();
  }
  
  Danbooru.Unapproval.hide_or_show_unapprove_link = function() {
    if (Danbooru.meta("post-is-unapprovable") != "true") {
      $("a#unapprove").hide();
    }
  }
  
  Danbooru.Unapproval.initialize_unapprove = function() {
    $("#unapprove-dialog").dialog({
      autoOpen: false, 
      width: 400,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#unapprove-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $("a#unapprove").click(function(e) {
      e.preventDefault();
      $("#unapprove-dialog").dialog("open");
    });
  }
})();

$(document).ready(function() {
  Danbooru.Unapproval.initialize_all();
});
