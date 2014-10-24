
# lib/toolbar-view

{$, $$, View}  = require 'atom'
Finder     = require './finder'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-horiz', tabindex:-1, =>
      @span outlet:'createBtn', class:'create-btn'
              
  initialize: (commandToolbar, @state) ->
    @buttons = []
    @setSide null, yes
    for btn in (@state.buttons ?= []) then @addBtn btn...
    
    @subscribe @createBtn, 'click', (e) =>
      new Finder().attach (name) => @addBtn name, name, yes
  
  addBtn: (label, cmd, newBtn) ->
    @createBtn.after (newBtnView = $$ -> @div class:'btn', label)
    @setSide null, yes
    newBtnView.attr 'data-cmd', cmd
    if newBtn 
      @buttons.unshift newBtnView
      @state.buttons.unshift [label, cmd]
    else 
      @buttons.push newBtnView
      
  setSide: (side, refresh) ->
    if side then @state.side = side
    if not refresh and side is @state.side then return
    @state.side ?= 'top'
    lftRight = =>
      @removeClass('toolbar-vert').addClass('toolbar-horiz')
      @find('.btn').css display: 'inline-block'
    topBottom = =>
      @removeClass('toolbar-horiz').addClass('toolbar-vert')
      @find('.btn').css display: 'block'
    @detach()
    switch @state.side
      when 'left'   then topBottom(); atom.workspaceView.prependToLeft  @
      when 'right'  then topBottom(); atom.workspaceView.appendToRight  @
      when 'bottom' then lftRight();  atom.workspaceView.appendToBottom @
      else               lftRight();  atom.workspaceView.prependToTop   @
        
  edit: (idx) ->
    
    
  destroy: ->
    @unsubscribe()
    @detach()

