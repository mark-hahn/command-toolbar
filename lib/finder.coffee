_ = require 'underscore-plus'
{$, $$, SelectListView} = require 'atom-space-pen-views'

module.exports =
class CommandPaletteView extends SelectListView
  @activate: ->
    new CommandPaletteView

  keyBindings: null

  initialize: ->
    super
    @addClass('command-toolbar-palette overlay from-top')

  getFilterKey: ->
    'displayName'

  attach: (@callback) ->
    @storeFocusedElement()

    # if @previouslyFocusedElement[0] and @previouslyFocusedElement[0] isnt document.body
    #   @eventElement = @previouslyFocusedElement
    # else
    #   @eventElement = atom.workspaceView
    # @keyBindings = atom.keymap.findKeyBindings(target: @eventElement[0])
    
    workSpaceView = atom.views.getView atom.workspace
    @keyBindings = atom.keymap.findKeyBindings target: workSpaceView
    commands = atom.commands.findCommands      target: workSpaceView
    commands = _.sortBy commands, 'displayName'
    @setItems commands

    $(workSpaceView).append @
    @focusFilterEditor()

  viewForItem: ({name, displayName}) ->
    keyBindings = @keyBindings
    $$ ->
      @li class: 'event', 'data-event-name': name, =>
        @div class: 'pull-right', =>
          for binding in keyBindings when binding.command is name
            @kbd _.humanizeKeystroke(binding.keystrokes), class: 'key-binding'
        @span displayName, title: name

  confirmed: ({name}) ->
    @cancel()
    @closest('.command-toolbar-palette').remove()
    @callback name
    
  cancelled: ->
    @closest('.command-toolbar-palette').remove()
    