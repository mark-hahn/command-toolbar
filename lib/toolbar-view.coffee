
# lib/toolbar-view

{$, View}  = require 'atom'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-vert', tabindex:-1, =>
      @span class:'settings-btn'
      
      @div  class:'btn', 'ct:tgl'
      @div  class:'btn', 'btn2'
      @div  class:'btn', 'btn3'
      @div  class:'btn', 'btn4'
        
  initialize: (commandToolbar) ->
    atom.workspaceView.appendToLeft @
    
    # @subscribe @, 'click', (e) ->
    #   if (classes = $(e.target).attr 'class') and 
    #      (btnIdx  = classes.indexOf 'octicon-') > -1
    #     switch classes[btnIdx+8...]
    #       when 'globe'       then command.destroyToolbar()
    #       when 'arrow-left'  then command.back()
    #       when 'arrow-right' then command.forward()
    #       when 'sync'        then command.refresh()
    #       
    
  destroy: ->
    @unsubscribe()
    @detach()

