# Cherry Bomb Minesweeper - iOS - Swift 4
<p align="center"><img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/AppIcon.appiconset/Icon-180.png?raw=true" alt="Gear Icon" width="120"/> </p>

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
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/gear-icon.imageset/gear-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> - Tap to access the Options screen to toggle sound and set minefield difficulties
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/cherry-bomb-icon.imageset/Icon-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> - Tap to start a new game with the current difficulty
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/shovel-icon.imageset/shovel-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/flag-icon.imageset/Icon-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> - Tap to toggle between "reveal cell" and "flag cell"
	
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

- **Images**
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/cherry-bomb-icon.imageset/Icon-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> [Cherry Bomb Icon](https://www.1001freedownloads.com/free-clipart/cartoon-bomb)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/gear-icon.imageset/gear-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> [Gear Icon](https://www.1001freedownloads.com/free-clipart/architetto-ruota-dentata-2)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/shovel-icon.imageset/shovel-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> [Shovel Icon](https://www.1001freedownloads.com/free-clipart/shovel-4) (Altered handle color)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/flag-icon.imageset/Icon-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> [Flag Icon](https://www.1001freedownloads.com/free-clipart/game-marbles-flags) (Used the Red flag with slight alterations)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/boom-icon.imageset/Icon-120.png?raw=true" alt="Gear Icon" width="30" height="30"/> [BOOM Icon](https://www.1001freedownloads.com/free-clipart/boom)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/brick-tile-icon.imageset/brick-tile-icon-120.jpg?raw=true" alt="Gear Icon" width="30" height="30"/> [Brick Background](https://www.1001freedownloads.com/free-clipart/brick-tile)
	- <img src="https://github.com/duyngn/cherry-bomb-sweeper-ios/blob/master/CherryBombSweeper/Assets.xcassets/music-icon.imageset/brick-tile-icon-120.jpg?raw=true" alt="Music Icon" width="30" height="30"/> [Music Icon](https://www.1001freedownloads.com/free-clipart/double_croche)
	
- **Font**
	- [Digital-7](http://www.styleseven.com/php/get_product.php?product=Digital-7) - created by http://www.styleseven.com/
	
- **Sound**
	- [Background Music](https://freesound.org/people/RokZRooM/sounds/344778/)
	- [Explosion](https://freesound.org/people/Iwiploppenisse/sounds/156031/)
	- [Flag Drop](https://freesound.org/people/plasterbrain/sounds/237422/)
	- [Reveal](https://freesound.org/people/NenadSimic/sounds/171697/)
	- [Probe](https://freesound.org/people/kwahmah_02/sounds/256116/)
	- [Icon Selection](https://freesound.org/people/PaulMorek/sounds/330052/)
	- [Beep Beep](https://freesound.org/people/Kodack/sounds/258193/)
	- [New Game](https://freesound.org/people/InspectorJ/sounds/403009/)
	- [Option Selection](https://freesound.org/people/pan14/sounds/263133/)
	- [Game Win](https://freesound.org/people/LittleRobotSoundFactory/sounds/270404/)
	- [Cancel](https://freesound.org/people/hodomostvarujemritam/sounds/171273/)
