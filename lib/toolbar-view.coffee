
# lib/toolbar-view

{$, View}  = require 'atom'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-horiz', tabindex:-1, =>
      @span class:'settings-btn'
      
      @div  class:'btn', 'Cmd Tab'
      @div  class:'btn', 'btn2'
      @div  class:'btn', 'btn3'
      @div  class:'btn', 'btn4'
        
  initialize: (commandToolbar, @state) ->
    @setSide @state.side
    
    @setSide 'top'
    setTimeout (=> @setSide 'bottom'),  3000
    
    # @subscribe @, 'click', (e) ->
    #   if (classes = $(e.target).attr 'class') and 
    #      (btnIdx  = classes.indexOf 'octicon-') > -1
    #     switch classes[btnIdx+8...]
    #       when 'globe'       then command.destroyToolbar()
    #       when 'arrow-left'  then command.back()
    #       when 'arrow-right' then command.forward()
    #       when 'sync'        then command.refresh()
    #       
    
  setSide: (side = 'top') ->
    @state.side = side
    lftRight = =>
      @removeClass('toolbar-vert').addClass('toolbar-horiz')
      @find('.btn').css display: 'inline-block'
    topBottom = =>
      @removeClass('toolbar-horiz').addClass('toolbar-vert')
      @find('.btn').css display: 'block'
    @detach()
    switch side
      when 'top'    then lftRight();  atom.workspaceView.prependToTop   @
      when 'bottom' then lftRight();  atom.workspaceView.appendToBottom @
      when 'left'   then topBottom(); atom.workspaceView.prependToLeft  @
      when 'right'  then topBottom(); atom.workspaceView.appendToRight  @
        
    
  destroy: ->
    @unsubscribe()
    @detach()

