# encoding: utf-8
module SpellingsHelper
  STATUS_IMAGES = {
    :added => "add.gif",
    :primary => "primary.png",
    :validated => "tick.png",
    :confirmed => "bullet_green.png",
    :suggested => "bullet_orange.png",
    :merged => "arrow_join.png",
    :wiki => "wiki.ico"
  }
  def spelling_status(spelling)
    image = STATUS_IMAGES[spelling.status]
    image && image_tag(image)
  end

  def change_status(spelling,status)
    link_to image_tag(STATUS_IMAGES[status]), {:controller => "spellings", 
      :action => "change_status", :id => spelling, :status => status}, 
      :"data-update" => related_id(spelling,"spelling"), :remote => true
  end
end
