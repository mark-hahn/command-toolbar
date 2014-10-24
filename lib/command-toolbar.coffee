
# lib/command-toolbar.coffee

ToolbarView = require './toolbar-view'

class CommandToolbar
  configDefaults: 
    alwaysShowToolbarOnLoad: yes

  activate: (@state) ->
    if atom.config.get 'command-toolbar.alwaysShowToolbarOnLoad'
      @state.opened = yes
    if @state.opened then @toggle yes
    
    atom.workspaceView.command "command-toolbar:toggle", => @toggle()
    
  toggle: (forceOn) ->
    if forceOn or not @state.opened
      @state.opened = yes
      @toolbarView ?= new ToolbarView @, @state
      @toolbarView.show()
    else
      @state.opened = no
      @toolbarView?.hide()
          
  getToolbar:     -> @toolbarView
  destroyToolbar: -> @toolbarView?.destroy()
    
  serialize: -> @state
  
  deactivate: ->
    @destroyToolbar()
    
module.exports = new CommandToolbar
