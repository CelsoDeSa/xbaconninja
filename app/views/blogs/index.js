$('#videos').append('<%= j render("video") %>');
<% if @videos.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@videos) %>');
<% else %>
  $('.pagination').remove();
<% end %>

$('#pictures').append('<%= j render("picture") %>');
<% if @pictures.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@pictures) %>');
<% else %>
  $('.pagination').remove();
<% end %>