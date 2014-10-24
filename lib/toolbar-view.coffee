
# lib/toolbar-view

{$, $$, View}  = require 'atom'
Finder     = require './finder'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-horiz', tabindex:-1, =>
      @span outlet:'createBtn', class:'create-btn'
              
  initialize: (commandToolbar, @state) ->
    @update null, yes
    for btn in (@state.buttons ?= []) then @addBtn btn...
    
    @subscribe @createBtn, 'click', (e) =>
      new Finder().attach (name) => @addBtn name, name, yes
      false
      
    @setupBtnEvents()
  
  update: (side, refresh) ->
    @stopEditing()
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
        
  get$Btn: (e) -> $(e.target).closest('.btn')
    
  addBtn: (label, cmd, newBtn) ->
    @stopEditing()
    @createBtn.after (newBtnView = $$ -> 
      @div class:'btn native-key-bindings', tabIndex:-1, label)
    @update null, yes
    newBtnView.attr 'data-cmd', cmd
    if newBtn then @state.buttons.unshift [label, cmd]
    
  editBtn: (e) -> 
    if @buttonEditing and @buttonEditing[0] is e.target 
      return
    @stopEditing()
    $btn = @get$Btn e
    $btn.attr contenteditable: yes
    $btn.css cursor: 'text'
    $btn.focus()
    @buttonEditing = $btn
    
  stopEditing: ->
    if not @buttonEditing then return
    @buttonEditing.css cursor: 'pointer'
    @buttonEditing.blur()
    @buttonEditing.attr contenteditable: no
    @buttonEditing = null
    
    stateBtns = @state.buttons = []
    @find('.btn').each ->
      $btn = $ @
      label = $btn.text()
      cmd   = $btn.attr 'data-cmd'
      stateBtns.push [label, cmd]
  
  btnClick: (e) ->
    if @buttonEditing and @buttonEditing[0] isnt e.target
      @stopEditing()

  btnKeyDown: (e) -> 
    if e.which in [9, 13] then @stopEditing(); false 
    
  setupBtnEvents: ->
    @subscribe atom.workspaceView, 'click',                => @stopEditing()
    @subscribe @,                  'click',                -> false
    @subscribe @,                  'click',    '.btn', (e) => @btnClick   e
    @subscribe @,                  'dblclick', '.btn', (e) => @editBtn    e
    @subscribe @,                  'keydown',  '.btn', (e) => @btnKeyDown e

  destroy: ->
    @unsubscribe()
    @detach()

