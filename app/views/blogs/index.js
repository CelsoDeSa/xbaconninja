$('#videos').append('<%= j render("video") %>');
<% if @videos.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@videos) %>');
<% else %>
  $('.pagination').remove();
<% end %>

$('#pictures1').append('<%= j render("picture1") %>');
<% if @pictures1.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@pictures1) %>');
<% else %>
  $('.pagination').remove();
<% end %>

$('#pictures2').append('<%= j render("picture2") %>');
<% if @pictures2.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@pictures2) %>');
<% else %>
  $('.pagination').remove();
<% end %>