$('#pictures').append('<%= j render("picture") %>');
<% if @pictures.next_page %>
  $('.pagination').replaceWith('<%= j will_paginate(@pictures) %>');
<% else %>
  $('.pagination').remove();
<% end %>
