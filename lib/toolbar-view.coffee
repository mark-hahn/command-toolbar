
# lib/toolbar-view

{$, $$, View}  = require 'atom'
Finder     = require './finder'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-horiz', tabindex:-1, =>
      @span outlet:'createBtn', class:'create-btn'
              
  initialize: (commandToolbar, @state) ->
    @update 'top', yes
    @createBtn.setTooltip title: 'Create Button or Drag Toolbar'
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
    if newBtn 
      oldLabel = null
      @find('.btn').each ->
        $btn = $ @
        if $btn.attr('data-cmd') is cmd
          oldLabel = $btn.text()
          atom.confirm
            message: 'command-toolbar Error:\n'
            detailedMessage: 'The command "' + cmd + '" ' +
                              'already exists with label "' + oldLabel + '".'
            buttons: ['OK']
          return false
      if oldLabel? then return
    newBtnView = $$ -> 
      @div class:'btn native-key-bindings', tabIndex:-1, label
    if newBtn then @createBtn.after newBtnView
    else @append newBtnView
    newBtnView.setTooltip title: cmd
    @update null, yes
    newBtnView.attr 'data-cmd', cmd
    if newBtn then @state.buttons.unshift [label, cmd]
    
  startEditing: (e) -> 
    if @buttonEditing and @buttonEditing[0] is e.target 
      return
    @stopDragging()
    @stopEditing()
    $btn = @get$Btn e
    $btn.attr contenteditable: yes
    $btn.css cursor: 'text'
    $btn.focus()
    @buttonEditing = $btn
    
  stopEditing: ->
    if not @buttonEditing then return
    @buttonEditing.css cursor: 'pointer'
    @buttonEditing.attr contenteditable: no
    @state.buttons[@buttonEditing.index()-1][0] = @buttonEditing.text()
    @buttonEditing = null
  
  executeCmd: (e) ->
    prevFocusedEle = $ ':focus'
    if prevFocusedEle[0] and prevFocusedEle[0] isnt document.body
      eventEle = prevFocusedEle
    else
      eventEle = atom.workspaceView
    if @buttonEditing and @buttonEditing[0] isnt e.target then @stopEditing()
    $btn = @get$Btn e
    cmd  = $btn.attr 'data-cmd'
    eventEle[0].dispatchEvent new CustomEvent cmd, bubbles: true, cancelable: true
  
  btnClick: (e) ->
    if e.ctrlKey then @startEditing e; return
    if e.target is @buttonEditing?[0] then return
    @executeCmd e
    
  btnKeyDown: (e) -> 
    if e.which in [9, 13] 
      @stopEditing()
      false

  startDragging: (e) ->
    $btn = @get$Btn e
    $btn.focus()
    @initMouseX  = e.pageX
    @initMouseY  = e.pageY
    @draggingBtn = $btn
    @draggingBtn.addClass 'dragging'
    
  stopDragging: (del) ->
    if not @draggingBtn then return
    if del 
      @state.buttons.splice @draggingBtn.index()-1, 1
      @draggingBtn.remove()
    else @draggingBtn.removeClass 'dragging'
    @draggingBtn = null;
    false
    
  btnMousedown: (e) ->
    if @buttonEditing then return 
    console.log 'btnMousedown', e.pageY
    @startDragging e
    false

  mousemove: (e) ->
    if not @draggingBtn then return
    console.log 'mousemove', e.which, @initMouseY, e.pageY
    if @buttonEditing or (e.which & 1) is 0 then @stopDragging(); return
    [init, mouse] =
      (if @state.side in ['top', 'bottom'] then [@initMouseY, e.pageY]  \
                                           else [@initMouseX, e.pageX])
    if not (init - 60 < mouse < init + 60)
      @stopDragging yes
      return
    false
      
  setupBtnEvents: ->
    @subscribe atom.workspaceView, 'blur', '[contenteditable]', => @stopEditing()
    @subscribe atom.workspaceView, 'mouseup',                   => @stopDragging()
    @subscribe atom.workspaceView, 'mousemove',             (e) => @mousemove    e
    @subscribe @,                  'mousedown', '.btn',     (e) => @btnMousedown e
    @subscribe @,                  'keydown',   '.btn',     (e) => @btnKeyDown   e
    @subscribe @,                  'click',     '.btn',     (e) => @btnClick     e

  destroy: ->
    @unsubscribe()
    @detach()

