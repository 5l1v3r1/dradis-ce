class IssueTable
  $table: null
  selectedColumns: []

  constructor: ->
    @$table = $('#issue-table table')

    $('#issue-table').on('click', '.js-taglink', @tagSelected)

    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    $('#issue-table').on('confirm:complete', '#delete-selected', @deleteSelected)

    # Handle the showing / hiding of table columns
    $('.dropdown-menu.js-table-columns a').on 'click', @onColumnPickerClick

  deleteSelected: (element, answer) ->
    if answer
      $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
        $row = $(this).parent().parent()
        $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")
        $that = $(this)
        $.ajax $(this).data('url'), {
          method: 'DELETE'
          dataType: 'json'
          success: (data) ->
            # Delete row from the table
            $row.remove()
            # TODO: show placeholder if no issues left

            # Delete link from the sidebar
            $("#issue_#{data.id}").remove()

            if $('input[type=checkbox]:checked').length == 0
              $('.js-issue-actions').css('display', 'none')

          error: (foo,bar,foobar) ->
            $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
        }

    # prevent Rails UJS from doing anything else.
    false

  tagSelected: (event) ->
    $target = $(event.target)
    event.preventDefault()

    $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
      $this = $(this)

      $this.prop('checked', false)
      $row = $this.parent().parent()
      $($row.find('td')[2]).replaceWith("<td class=\"loading\">Loading...</td>")

      url   = $this.data('url')
      data  = { issue: { tag_list: $target.data('tag') } }
      $that = $this

      $.ajax url, {
        method: 'PUT',
        data: data,
        dataType: 'json',
        success: (data) ->
          issue_id = $that.val()

          $($row.find('td')[2]).replaceWith(data.tag_cell)
          $("#issues #issue_#{issue_id}").replaceWith(data.issue_link)
          if $('input[type=checkbox]:checked').length == 0
            $('.js-issue-actions').css('display', 'none')

        error: (foo,bar,foobar) ->
          $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
      }


  onColumnPickerClick: (event) =>
    $target = $(event.currentTarget)
    val     = $target.attr('data-value')
    $input  = $target.find('input')

    if ((idx = @selectedColumns.indexOf(val)) > -1)
      @selectedColumns.splice(idx, 1)
      setTimeout ->
        $input.prop('checked', false)
      , 0
    else
      @selectedColumns.push(val)
      setTimeout ->
        $input.prop('checked', true)
      , 0

    $(event.target).blur()
    @showHideColumns()
    false

  showHideColumns: =>
    that = this
    $.each @$table.find('thead th'), (index, th)->
      if (column = $(th).data('column'))
        if that.selectedColumns.indexOf(column) > -1
          console.log("show #{column}")
        else
          console.log("hide #{column}")

jQuery ->
  if $('body.issues.index').length

    # Checkbox behavior: select all, show 'btn-group', etc.
    $('#select-all').click ->
      $('input[type=checkbox]').not(this).prop('checked', $(this).prop('checked'))


    $('input[type=checkbox].js-multicheck').click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $('input[type=checkbox].js-multicheck').each ->
          _select_all = $(this).prop('checked')
          _select_all

      $('#select-all').prop('checked', _select_all)

    $('input[type=checkbox].js-multicheck').click ->
      if $('input[type=checkbox]:checked').length
        $('.js-issue-actions').css('display', 'inline-block')
      else
        $('.js-issue-actions').css('display', 'none')


    $('#js-table-filter').on 'keyup', ->
        rex = new RegExp($(this).val(), 'i')
        $('tbody tr').hide();
        $('tbody tr').filter( ->
          rex.test($(this).text());
        ).show();

    new IssueTable
