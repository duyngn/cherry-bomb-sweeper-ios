# Cherry Bomb Minesweeper - iOS - Swift 4

A modern take on the classic game Minesweeper. Written fully in Swift 4 with iPhone X screen support.

## Feature Highlights
 - Three pre-set difficulties: Easy, Intermediate, Expert
 - Custom grid configuration up to 30 x 30 grid with 200 mines.
 - Background music with toggle on/off in Options
 - Game sound effects with toggle on/off in Options
 - Long press to quickly drop flag onto cell.
 - Pan and Zoom around the grid
 - Supports Portrait and Landscape orientation.

## Controls
- **Top Action Bar**
	- **Gear Icon** - Tap to access the Options screen to toggle sound and set minefield difficulties
	- **Bomb Icon** - Tap to start a new game with the current difficulty
	- **Action Icon** - Tap to toggle between "reveal cell" (shovel icon) and "flag cell" (flag icon)
	
- **Gameplay**
	- With Action Icon showing the "Shovel", tap to reveal cell
	- With Action Icon showing the "Flag", tap to mark a cell as a Bomb cell.
	- Long press on any untouched cells to quickly mark that cell as a Bomb cell.
	- Tap any revealed cell with an adjacent number to probe potential Bomb cells.
	- When tapping on a revealed cell with an adjacent number that has already been satisfied by the equal amount of flagged cells around it, all remaining untouched cells will be revealed.

## Screenshots
<p align="center">
<img src="https://user-images.githubusercontent.com/5741896/35718857-3d37fac2-079b-11e8-9c46-05d2d17742b5.jpg" width="300"/> <img src="https://user-images.githubusercontent.com/5741896/35718813-0ab93a7a-079b-11e8-928d-3c2919db4701.jpg" width="300"/>
</p>
<p align="center">
<img src="https://user-images.githubusercontent.com/5741896/35718871-5260ade0-079b-11e8-85b3-03ce02846ad2.jpg" width="300"/> <img src="https://user-images.githubusercontent.com/5741896/35718885-60939ddc-079b-11e8-9f68-232cf37839cd.jpg" width="300"/>
</p>

## TODO

- Implement stat tracking and persist to CoreData
- Implement stat screen accessible via the countdown timer
- Implement a Credits screen to properly credit all the free assets used
- Optimize large grid generation

## Credits

// TODO
