# Start here: central hub prototype

This folder contains an early visual prototype for the game's spawn plaza. The script builds the hub in Roblox at runtime; the SVG is a top-down concept sketch for review.

## Try it in Roblox Studio without Rojo

1. Download the repository as a ZIP from GitHub and unzip it.
2. In Roblox Studio, open the place you want to preview.
3. In Explorer, find `ServerScriptService`, click its **+**, and add a regular **Script**.
4. Open `Brawl Card/src/server/Design/HubDesign.server.lua` in a text editor, copy all of its contents, and paste them into that Script.
5. Press **Play**. Look in `Workspace` for the generated `HubDesign` folder and in Output for the completion message.

The Script must be under `ServerScriptService`; putting code in a Folder or the command bar will not run it as part of the game.

## Sync the repository with Rojo

The `default.project.json` already maps `src/server/Design` into `ServerScriptService`. Open the `Brawl Card` project folder in Rojo, connect the Rojo Studio plugin, and start a Play test. `WorldSetup.server.lua` creates the two base areas; `HubDesign.server.lua` builds the plaza on top of the spawn area.

## What this prototype includes

- A layered round plaza around the spawn, with a raised medallion and sculptural fountain.
- Planters, stylized trees, benches, warm lights, and a gently curved promenade.
- A welcome arch and a glowing gate that visually points toward the trade district.
- A top-down layout sketch in `HubConcept.svg`.

The gate is visual only in this prototype; it does not transfer players between places. This is a design pass for review, not the finished game systems. Running the Script again replaces the previous `Workspace/HubDesign` model instead of stacking another copy.
