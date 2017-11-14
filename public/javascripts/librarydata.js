function staff_list_changed(){
  if (($('table#staff_list tbody tr:not(.template):last input:text[value!=""]').length > 0) || ($('table#staff_list tbody tr:visible').length == 0)) {
    $('table#staff_list tbody tr.template').clone().removeClass('template').css('display', '').appendTo($('table#staff_list tbody'));
  }
  // insert up/down/delete links
  var rows = $('table#staff_list tbody tr:not(.template)');
  var num_real_rows = (rows.length - 1)
  for(var i = 0; i < num_real_rows; i++) {
    var actions = $(rows[i]).find('td.actions');
    $(rows[i]).find('td.actions').html('');
    actions.append(' <a href="#" class="delete_link"><span>delete</span></a> ')
    if(i > 0) actions.append(' <a href="#" class="up_link"><span>up</span></a> ')
    if((i + 1) < num_real_rows) actions.append(' <a href="#" class="down_link"><span>down</span></a> ')
  }
}

function social_links_list_changed(){
  // if text in last row OR no visible rows, add ANOTHER last row
  if (($('table#social_links_list tbody tr:not(.template):last input:text[value!=""]').length > 0) || ($('table#social_links_list tbody tr:visible').length == 0)) {
    $('table#social_links_list tbody tr.template').clone().removeClass('template').css('display', '').appendTo($('table#social_links_list tbody'));
  }
  // insert up/down/delete links
  var rows = $('table#social_links_list tbody tr:not(.template)');
  var num_real_rows = (rows.length - 1)
  for(var i = 0; i < num_real_rows; i++) {
    var actions = $(rows[i]).find('td.actions');
    $(rows[i]).find('td.actions').html('');
    actions.append(' <a href="#" class="delete_link"><span>delete</span></a> ')
    if(i > 0) actions.append(' <a href="#" class="up_link"><span>up</span></a> ')
    if((i + 1) < num_real_rows) actions.append(' <a href="#" class="down_link"><span>down</span></a> ')
  }
  // insert tips, prefixes, etc.
  $('#social_links_list select option:selected').each(function(){
    if($(this).data('username-okay')) {
      $(this).closest('tr').find('td .field_desc').css('display', 'block').text('Please enter a username.');
    } else if($(this).val() != '') {
      $(this).closest('tr').find('td .field_desc').css('display', 'block').text('Please enter a web address.');
    }
    $(this).closest('tr').find('td .field_prefix').text('').text($(this).data('prefix'));
  });
}

$(function(){
  // tabs
  $('#tabs').tabs();
  
  // buttons
  $('.button').button();
  $('input:button[data-href]').click(function(){
    window.location.href = $('body').data('base-url') + $(this).data('href');
    return false;
  });
  
  // links to tabs (cross-references)
  $('a.tablink').click(function(){
    $('#tabs .ui-tabs-nav a[href=' + $(this).attr('href') + ']').click();
    return false;
  });
  
  // all/some/none drop-down boxes
  $('select.all_some_none').before('<img class="borrowing_policy" src="#" />').on('change keyup', function(){
    $(this).closest('p').find('img.borrowing_policy').attr('src', $('body').data('base-url') + '/images/borrowing_policies/' + $(this).val() + '.gif');
  }).change();
  
  // staff list
  $('table#staff_list').on('change keyup', 'input', staff_list_changed);
  $('table#staff_list').on('blur', 'input:not(.template)', function(){
    // delete empty rows on blur
    var tr = $(this).closest('tr');
    if (tr.find('input:text[value!=""]').length == 0) {
      tr.remove();
      staff_list_changed(); // in case we just removed trailing blank row, re-add
    }
  });
  $('table#staff_list').on('click', '.up_link', function(){
    var this_row = $(this).closest('tr');
    this_row.insertBefore(this_row.prev());
    staff_list_changed();
    return false;
  });
  $('table#staff_list').on('click', '.down_link', function(){
    var this_row = $(this).closest('tr');
    this_row.insertAfter(this_row.next());
    staff_list_changed();
    return false;
  });
  $('table#staff_list').on('click', '.delete_link', function(){
    $(this).closest('tr').remove();
    staff_list_changed();
    return false;
  });
  staff_list_changed();

  // social links list
  $('table#social_links_list').on('change keyup', 'input, select', social_links_list_changed);
  $('table#social_links_list').on('blur', 'input:not(.template)', function(){
    // delete empty rows on blur
    var tr = $(this).closest('tr');
    if (tr.find('input:text[value!=""]').length == 0) {
      tr.remove();
      social_links_list_changed(); // in case we just removed trailing blank row, re-add
    }
  });
  $('table#social_links_list').on('click', '.up_link', function(){
    var this_row = $(this).closest('tr');
    this_row.insertBefore(this_row.prev());
    social_links_list_changed();
    return false;
  });
  $('table#social_links_list').on('click', '.down_link', function(){
    var this_row = $(this).closest('tr');
    this_row.insertAfter(this_row.next());
    social_links_list_changed();
    return false;
  });
  $('table#social_links_list').on('click', '.delete_link', function(){
    $(this).closest('tr').remove();
    social_links_list_changed();
    return false;
  });
  social_links_list_changed();

  // if hash, select appropriate tab
  if(window.location.hash != '') {
    $('a[href=#tab_' + window.location.hash.substring(1,window.location.hash.length) + ']').click();
  }

  // opening hours table
  $('#opening_hours tfoot').show().find('a.copy_from_previous').click(function(){
    var prev_column_pair = $(this).closest('td').prevAll().length; // count columns to left to work out where we are
    var i = (prev_column_pair * 2) - 4;
    $(this).closest('table').find('tbody tr').each(function(){
      $($(this).find('td')[i + 2]).find('input').val($($(this).find('td')[i + 0]).find('input').val());
      $($(this).find('td')[i + 3]).find('input').val($($(this).find('td')[i + 1]).find('input').val());
    });
    return false;
  });
  $('#opening_hours tbody a.copy_from_above').click(function(){
    var this_row = $(this).closest('tr');
    var prev_row = this_row.prev();
    var this_tds = this_row.find('td');
    var prev_tds = prev_row.find('td');
    for(var i = 0; i < 12; i++){
      $(this_tds[i]).find('input').val($(prev_tds[i]).find('input').val());
    }
    return false;
  });
});
