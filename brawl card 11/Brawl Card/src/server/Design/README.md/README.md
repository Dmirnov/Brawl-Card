# Design

`HubDesign.server.lua` builds the first version of the central spawn plaza as a standalone server script. It is intentionally separate from `WorldSetup.server.lua`, so the `Design` folder can be copied into a newer project later.

The scene includes a layered circular plaza, a raised spawn medallion, a sculptural fountain, four tree planters, benches, warm path lights, a curved promenade with transition steps, a sculptural entry arch, and a glowing gate that points toward the trade district. Gold and blue inlays guide the route. Seasonal themes are not included yet; the palette and landmarks are kept in code so later visual variants can be added without rebuilding the layout.

`HubConcept.svg` is a shareable top-down layout sketch for design discussion. It is a concept plan, not a screenshot or finished render from Roblox Studio.

The script creates its objects under `Workspace/HubDesign`, waits for `SpawnWorld` when that base world exists, moves the existing spawn marker onto the raised plaza, and can be run repeatedly without stacking duplicate plaza objects.

## Preview with Rojo

The project mapping includes this folder under `ServerScriptService`. From the project folder, start Rojo and connect the Rojo Studio plugin, then start a Play test. The plaza overlays the current spawn area and the promenade leads toward the trade district.

## Move to a newer GitHub project

Copy the whole `Design` folder into `src/server/Design` in the newer project. In `default.project.json`, make sure the `ServerScriptService` object contains this mapping alongside the other server scripts:

```json
"Design": {
  "$path": "src/server/Design"
}
```

Upload the folder and the mapping change to GitHub. In Roblox Studio without Rojo, create a regular `Script` under `ServerScriptService` and paste the contents of `HubDesign.server.lua` into it.
