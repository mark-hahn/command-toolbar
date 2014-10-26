
# lib/toolbar-view

{$, $$, View}  = require 'atom'
Finder     = require './finder'

module.exports =
class ToolbarView extends View
  
  @content: ->
    @div class:'command-toolbar toolbar-horiz', tabindex:-1, =>
      @div outlet:'newBtn', class:'new-btn command-toolbar-btn'
              
  initialize: (commandToolbar, @state) ->
    @updateSide null, yes
    closeTtEvents = 'mousedown mouseout mouseleave'
    @subscribe @, 'mouseover',   '.command-toolbar-btn', (e) => @chkTooltip e
    @subscribe @, closeTtEvents, '.command-toolbar-btn',     => @closeTooltip()
    for btn in (@state.buttons ?= []) then @addBtn btn...
    @subscribe @newBtn, 'click', (e) =>
      new Finder().attach (name) => @addBtn name, name, yes
      false
    @setupBtnEvents()
    
  chkTooltip: (e) ->
    now = Date.now()
    @tooltipHoverMS ?= now
    if now < @tooltipHoverMS + 1000 
      @tooltipTimeout = setTimeout (=> @chkTooltip e), 50
      return
    @closeTooltip()
    ofs    = ($btn = $(e.target)).offset()
    newBtn = ($btn.is ':first-child')
    wid    = $btn.width() + (if newBtn then 10 else 0)
    hgt    = $btn.height()
    winX   = atom.workspaceView.width()
    winY   = atom.workspaceView.height()
    text   = if newBtn then 'Create Button Or Drag Toolbar'  \
                     else $btn.attr 'data-cmd'
    style = switch @state.side
      when 'top'    then "left:  #{ofs.left}px;        top:    #{ofs.top+hgt+15}px"  
      when 'right'  then "right: #{winX-ofs.left+5}px; top:    #{ofs.top-3}px"
      when 'bottom' then "left:  #{ofs.left}px;        bottom: #{winY-ofs.top+5}px"
      when 'left'   then "left:  #{ofs.left+wid+15}px;  top:    #{ofs.top-3}px"
    @$tooltip = $ "<div class='command-toolbar-tooltip' style='#{style}'>#{text}</div>"
    atom.workspaceView.append @$tooltip
    @tooltipCloseTimeout = setTimeout (=> @closeTooltip()), 2000
    return false
        
  closeTooltip: ->
    if @tooltipTimeout      then clearTimeout @tooltipTimeout
    if @tooltipCloseTimeout then clearTimeout @tooltipCloseTimeout
    @tooltipTimeout = @tooltipCloseTimeout = @tooltipHoverMS = null
    if @$tooltip
      @$tooltip.remove()
      @$tooltip = null
     
  updateSide: (side, refresh) ->
    @stopEditing()
    if not side and not refresh then return
    if not refresh and side is @state.side then return
    if side then @state.side = side
    @state.side ?= 'top'
    lftRight = =>
      @removeClass('toolbar-vert').addClass('toolbar-horiz')
      @find('.btn').css display: 'inline-block'
    topBottom = =>
      @removeClass('toolbar-horiz').addClass('toolbar-vert')
      @find('.btn').css display: 'block'
    @detach()
    switch @state.side
      when 'left'   
        topBottom()
        atom.workspaceView.prependToLeft  @
      when 'right'  
        topBottom()
        atom.workspaceView.appendToRight  @
      when 'bottom' 
        lftRight()
        atom.workspaceView.appendToBottom @
      else               
        lftRight()
        atom.workspaceView.prependToTop   @
        
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
      @div class:'btn native-key-bindings command-toolbar-btn', tabIndex:-1, label
    if newBtn then @newBtn.after newBtnView
    else @append newBtnView
    @updateSide null, yes
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
    else eventEle = atom.workspaceView
    if @buttonEditing and @buttonEditing[0] isnt e.target then @stopEditing()
    cmd = @get$Btn(e).attr 'data-cmd'
    eventEle[0].dispatchEvent new CustomEvent cmd, bubbles: true, cancelable: true
  
  btnClick: (e) ->
    if e.ctrlKey then @startEditing e; return
    if e.target is @buttonEditing?[0] then return
    @executeCmd e
    
  btnKeyDown: (e) -> 
    if e.which in [9, 13] 
      @stopEditing()
      false
      
  startDraggingToolbar: (e) ->
    @initMouseX  = e.pageX
    @initMouseY  = e.pageY
    @draggingToolbar = yes
    @newBtn.addClass 'dragging'
    
  setToolbarPos: (e) ->
    distX  = e.pageX - @initMouseX
    distY  = e.pageY - @initMouseY
    distSq = distX*distX + distY*distY
    gridW = atom.workspaceView.width()  / 3
    gridH = atom.workspaceView.height() / 3
    inMiddleCol = (gridW < e.pageX < gridW*2)
    inMiddleRow = (gridH < e.pageY < gridH*2)
    side = switch
      when distSq < 3600                     then @state.side
      when inMiddleCol and e.pageY < gridH   then 'top' 
      when inMiddleRow and e.pageX > gridW*2 then 'right' 
      when inMiddleCol and e.pageY > gridH*2 then 'bottom' 
      when inMiddleRow and e.pageX < gridW   then 'left' 
    # console.log 'setToolbarPos', {side, x:e.pageX, y:e.pageY, distSq, gridW, gridH, inMiddleCol, inMiddleRow}
    @updateSide side
    
  startDragging: (e) ->
    $btn = @get$Btn e
    $btn.focus()
    @initMouseX  = e.pageX
    @initMouseY  = e.pageY
    @draggingBtn = $btn
    @draggingOrigIdx = $btn.index()-1
    @draggingBtn.addClass 'dragging'
    
  stopDragging: (del) ->
    @draggingToolbar = no
    @newBtn.removeClass 'dragging'
    if not @draggingBtn then return
    if del 
      @state.buttons.splice @draggingBtn.index()-1, 1
      @draggingBtn.remove()
    else @draggingBtn.removeClass 'dragging'
    @draggingBtn = null;
    false
    
  newBtnMouseDown: (e) ->
    if @buttonEditing then @stopEditing()
    @startDraggingToolbar e
    false
    
  btnMousedown: (e) ->
    if @buttonEditing then return 
    @startDragging e
    false
    
  chkDelete: (init, initOrth, pos, posOrth) ->
    if not (initOrth - 60 < posOrth < initOrth + 60)
      @stopDragging yes
      yes

  chkRearrange: (init, initOrth, pos, posOrth) ->
    ofs  = pos - init
    dist = Math.floor Math.abs(ofs) / 
                      (if @state.side in ['left', 'right'] then 5 else 20)
    if dist & 1 then return
    dist /= 2
    numBtns = @state.buttons.length
    newIdx = @draggingOrigIdx + (if ofs < 0 then -dist else dist)
    newIdx = Math.max 0, Math.min numBtns-1, newIdx
    curIdx = @draggingBtn.index()-1
    if newIdx is curIdx then return
    $btns = @find('.btn').remove()
    srcIdx = dstIdx = 0
    while dstIdx < numBtns
      switch 
        when dstIdx is   newIdx then @append $btns.eq curIdx;   dstIdx++
        when srcIdx isnt curIdx then @append $btns.eq srcIdx++; dstIdx++
        else srcIdx++
    buttons = @state.buttons = []
    @find('.btn').each ->
      $btn = $ @
      buttons.push [$btn.text(), $btn.attr 'data-cmd']

  mousemove: (e) ->
    if not @draggingBtn and not @draggingToolbar then return
    if @buttonEditing or (e.which & 1) is 0 then @stopDragging(); return
    if @draggingToolbar then @setToolbarPos e
    else
      posArr =
        (if @state.side in ['top', 'bottom'] 
             [@initMouseX, @initMouseY, e.pageX, e.pageY]
        else [@initMouseY, @initMouseX, e.pageY, e.pageX])
      if not @chkDelete posArr...
        @chkRearrange posArr...
    false
      
  setupBtnEvents: ->
    @subscribe atom.workspaceView, 'blur', '[contenteditable]', => @stopEditing()
    @subscribe atom.workspaceView, 'mouseup',                   => @stopDragging()
    @subscribe atom.workspaceView, 'mousemove',             (e) => @mousemove       e
    @subscribe @,                  'mousedown', '.new-btn', (e) => @newBtnMouseDown e
    @subscribe @,                  'mousedown', '.btn',     (e) => @btnMousedown    e
    @subscribe @,                  'keydown',   '.btn',     (e) => @btnKeyDown      e
    @subscribe @,                  'click',     '.btn',     (e) => @btnClick        e

  destroy: ->
    @unsubscribe()
    @detach()

