# utility functions to escape a query
# @param str the string to escape
escapeRegexp = (str) -> str.replace /([.?*+^$[\]\\(){}|-])/g, "\\$1"

# removes all img tags
# @param str a string possibly containing img tags
noImg = (str) -> str.replace /<img[^>]*>/g, ''

angular.module('contenteditable', [])
.directive('contenteditable', ->
  require: 'ngModel',
  link: (scope, elmt, attrs, ctrl) ->
    old_render = ctrl.$render # save for later

    # view -> model
    elmt.bind 'input', (e) ->
      scope.$apply ->
        ctrl.$setViewValue elmt.html()

    # model -> view
    ctrl.$render = ->
      old_render() if old_render != null # old_render? leads to linted js
      elmt.html ctrl.$viewValue
      # move cursor to the end
      el = elmt.get(0)
      range = document.createRange()
      sel = window.getSelection()
      if el.childNodes.length > 0
        el2 = el.childNodes[el.childNodes.length - 1]
        range.setStartAfter(el2)
      else
        range.setStartAfter(el)
      range.collapse(true)
      sel.removeAllRanges()
      sel.addRange(range)
)
.filter('typeaheadHighlight', ->
  # don't highlight anything!
  (matchItem, query) -> matchItem
)
.filter('ignoreImg', ->
  # when matching query against the items, ignore all img tags
  (items, query) ->
    item for item in items \
    when noImg(item).match(new RegExp(escapeRegexp(noImg(query)), 'gi'))
)