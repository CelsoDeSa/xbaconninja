# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
onEndless = ->
  $(window).off 'scroll', onEndless
  url = $('.paginator .next a').attr('href')
  $('.paginator').hide()
  if url && $(window).scrollTop() > $(document).height() - $(window).height() - 150
    $('.loader').show()
    $.getScript url, ->
      $(window).on 'scroll', onEndless
  else
    $(window).on 'scroll', onEndless

$(window).on 'scroll', onEndless

$(window).scroll()
