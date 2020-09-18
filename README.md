# Taurus
Taurus is an RPG made in the Godot engine. The player must explore and fight their way through several enemies in order to beat the game. The game will feature classic turn-based combat with some additional mechanics.

## Project Goals
- Complete a working video game within 1-3 months
- Export to HTML5 and publish on Newgrounds
- End product will be complete, but expandable

## Architecture
- Modes: Main Menu, Exploration, and Combat
- Game will consist of several independent scenes for each mode, each with their own set of nodes
- Godot Resources will be used to handle data storage
- All static code and data (enemies, abilities, etc) will be saved under the res:// path
- All persistent, non-static data (user stats, checkpoint, etc) will be saved under the user:// path
- Sprites will be attached to nodes, which may be added statically or programatically
- Animations and sounds will be added as nodes and activated/deactivated via scripts
- Game will use tile-based movement; collision will be determined by the type of grid the actors try moving to
- Signals will be emitted to communicate events between scripts
