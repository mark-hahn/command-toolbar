command-toolbar
===============

Atom editor toolbar with easily customized buttons for any command.

![Image inserted by Atom editor package auto-host-markdown-image](http://i.imgur.com/WKiq18y.gif?delhash=yjNlcuDbSIQTrEX)

## Installation

Run `apm install command-toolbar` or use the settings screen.

## Usage

* **Open/close** the toolbar using the command `command-toolbar:toggle`.  By default it is bound to the key `ctrl-6`.
* **Execute** a command by simply cicking on its button.
* **Create** a button by clicking on the first icon (three bars). A selection box identical to the command palette will pop up.  Choose a command and a new button for that command will appear in the toolbar.
* **Edit** a button label by clicking on the button with the ctrl key held down.
* **Rearrange** buttons by clicking and dragging them.
* **Delete** buttons by clicking on the button and dragging the cursor away from the bar.  The btn will not move before deletion.
* **Move** the toolbar to any of the four sides of the window by clicking on the first icon (three bars) and dragging the cursor to the middle of a different side.
* **View** the complete command assigned to a button by hovering over it for one second.



## Configuration

There is one setting `Always Show Toolbar On Load`. If it is checked then the toolbar will always be loaded when Atom is loaded.  If not checked then the toolbar will be visible on load only if it was visible when Atom was closed.

## License

command-toolbar is copyright Mark Hahn with the MIT license.