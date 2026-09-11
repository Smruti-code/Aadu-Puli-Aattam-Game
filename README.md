# Aadu Puli Aattam – Goats and Tigers Game

## Game Overview

Aadu Puli Aattam, also known as Goats and Tigers, is a traditional strategy board game from Tamil Nadu. This project implements a simplified digital version of the game using the Godot Engine.

The game consists of two types of pieces:

* 3 Tigers
* 15 Goats

The Tigers attempt to capture goats, while the Goats attempt to block the Tigers.

## Version 1 Features

* Playable Aadu Puli Aattam game
* 3 Tigers and 15 Goats
* Custom 23-point game board
* Turn-based gameplay
* Goat placement and movement
* Tiger movement
* Tiger capture mechanism
* Legal and illegal move validation
* Tiger and Goat winning conditions
* Restart Game option
* How to Play instructions
* Selected-piece highlighting
* Game status panel
* Game-over screen

## Requirements

To run the project, install the Godot Engine on your computer.

Recommended requirements:

* Godot Engine 4.x

## How to Install Godot

1. Visit the official Godot Engine website.
2. Download Godot Engine 4.x for your operating system.

## How to Run the Game

1. Download or clone this repository to your computer.
2. Open Godot Engine.
3. Select "Import" or "Import Existing Project".
4. Navigate to the downloaded project folder.
5. Select the `project.godot` file.
6. Import and open the project.
7. Once the project opens, click the "Run Project" button in Godot.
8. The Aadu Puli Aattam game will start.
9. Follow the instructions displayed in the game to play.

## How to Play

### Goat Player

The Goat player has 15 goats.

During the initial placement phase:

1. Select an empty point on the board.
2. A goat is placed on the selected point.
3. The turn changes to the Tigers.

After the goats have been placed, goats can move between connected points.

The objective of the Goat player is to block all the Tigers so that none of them can make a legal move.

### Tiger Player

The game starts with 3 Tigers placed on the board.

A Tiger can move to an adjacent empty point.

A Tiger can also capture a Goat by jumping over it to an empty connected point when the required board connection is available.

The objective of the Tiger player is to capture 5 goats.

## Winning Conditions

### Tigers Win

The Tigers win when they capture 5 goats.

### Goats Win

The Goats win when all Tigers are blocked and none of them have a legal move.

## Game Flow

1. Start the game.
2. Three Tigers are placed on the board.
3. Goat placement begins.
4. The Goat player places a goat.
5. The Tiger player moves or captures.
6. The game ends when either:

   * Tigers capture 5 goats, or
   * All Tigers are blocked.

## Version Information

Version: 1.0

Game: Aadu Puli Aattam – Goats and Tigers

## Project Description

This project is a digital implementation of the traditional Aadu Puli Aattam game from Tamil Nadu. Version 1 provides the playable game structure and serves as the foundation for future enhanced version 2.0.
