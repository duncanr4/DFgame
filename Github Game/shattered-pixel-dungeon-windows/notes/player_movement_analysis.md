# Shattered Pixel Dungeon movement analysis (from 3.3.6 jars)

## Commands run
- `jar tf app/core-3.3.6.jar | rg 'actors/hero|Hero|Dungeon|Level|PathFinder|Attack|move|cell|handle'`
- `javap -classpath app/core-3.3.6.jar -p com.shatteredpixel.shatteredpixeldungeon.actors.hero.Hero`
- `javap -classpath app/core-3.3.6.jar -c -p com.shatteredpixel.shatteredpixeldungeon.actors.hero.Hero`
- `javap -classpath app/core-3.3.6.jar -c -p com.shatteredpixel.shatteredpixeldungeon.actors.Char`
- `javap -classpath app/core-3.3.6.jar -c -p com.shatteredpixel.shatteredpixeldungeon.levels.Level`

## Key findings
1. `Hero.handle(int cell)` decides what an input click/tap means.
   - If a visible mob is in the destination, it chooses `HeroAction.Interact` or `HeroAction.Attack`.
   - Otherwise it can choose special actions (alchemy, mining, pickup/buy/open chest, unlock, level transition), and falls back to `HeroAction.Move`.

2. `Hero.actMove(HeroAction.Move)` executes the move action.
   - Calls `getCloser(dst)`.
   - If `getCloser` succeeds, movement proceeds.
   - If player tapped current tile and can self-trample, it presses the current cell and spends `1 / speed` time.

3. `Hero.getCloser(int dst)` performs pathing + movement rules.
   - Early exits if destination is current cell or if rooted.
   - For adjacent destination: checks occupancy and passability/avoid tiles.
   - For non-adjacent destination: uses cached path and/or `Dungeon.findPath(...)`, then takes first step.
   - Handles pit/chasm logic (jump confirmation/fall handling).
   - On successful step: sprite moves, `move(cell)` is called, hero spends move time (`delay / speed`), and auto-search runs.

4. `Char.move(int, boolean)` updates position and occupancy.
   - Handles vertigo random redirection on adjacent moves.
   - Leaves doors when stepping out, updates character position, then calls `Level.occupyCell(this)`.

5. `Level.occupyCell(Char)` and `Level.pressCell(...)` apply tile effects.
   - `occupyCell` applies terrain/blob effects and then calls `pressCell`.
   - `pressCell` handles hidden/visible traps, door entry, grass trample, well water effects, etc.

## Why movement feels turn-based
- In `getCloser`, successful movement spends time (`spend(delay / speed)`), so movement is an action that advances turn/energy economy.
- Various buffs/statuses alter movement time or legality (e.g., rooted, greater haste, levitation/chasm behavior).
