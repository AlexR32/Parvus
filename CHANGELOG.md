### Update 14/08/23
```markdown
# AR2
* player esp fixed with staff check enabled
* head expander fixed, now head doesn't collide with vehicle and other things

# BB
* silent aim fixed
* removed synapse check (useless right now)

# Options Tab
* moved discord section up slightly
```
### Update 10/08/23
```markdown
# AR2
+ added corpses esp
+ added head expander

* health now uses 'bounus' health too
* boxes now should not be too big sometime
* some code cleanup from old testing things
* silent aim prediction now will be always enabled
* silent aim 'body part priority' disabled (useless)
* added option to disable projectile tracers (was enabled always now its disabled by default)
* increased default speed for walkspeed and fly
* renamed no fall check to infinite jump
* increased jump height max slider value
* fixed map esp sometimes not showing some newly added players
* team check now uses squad members and should ignore them
* improved performance for vehicle mod
* silent aim prediction should be less buggy
* silent wallbang now uses silent aim prediction (previously not lol)
* fixed zombie esp
# BRM5
* fixed intel esp (typo)

***some notes:***
1. if you dont have projectile tracer when shooting or you have 'nan' or 'nan2' it means prediction miss calculates somehow
2. team check might be broken i didn't test it enough
i will be trying to fix this bugs in future updates
```
### Update 08/08/23
```markdown
# Global
- aimbot removed
- trigger bot removed (except bb)
# TWR
+ added item esp
* misc changes
```
### Update 07/08/23
```markdown
# AR2
* fixed some container esp things
+ added new lighting to misc
- removed lighting from visuals
* updated AR2 ESP Database
* updated vehicle section
* fixed melee aura
```
### Update 06/08/23
```markdown
# AR2
+ added fly
+ added zombie meleeaura
+ added player meleeaura
* misc fixes
```
### Update 05/08/23
```markdown
# AR2
* fixed
- melee aura removed
- anti zombie removed
- teleport removed
- fly removed
# Drawing
* fixed object esp transparency
```
### Update 4/08/23
```markdown
# Drawing
+ added out of view arrows
+ added chams/highlights

# BRM5
* should be fixed now
```
### Update 2/08/23
```markdown
# Drawing
* completely rewrited
+ added weapon text
+ added healthbar text
- removed out of view arrows (will be added again in future)
- removed chams/highlights (will be added again in future)

# AR2
+ added again
- only esp working right now

# RU
* silent aim fixed
```
### Update 1/08/23
```markdown
# BRM5
* NPC ESP enabled
* Intel ESP enabled
+ no stamina loss added
* team check fixed
* instant hit fixed

# Drawing Module
* some changes that should in theory dont crash roblox on execute
- temporary removed chams (highlights)
```
### Update 31/07/23
```markdown
# AR2
* disabled (high ban risk)

# BB
* fixed

# BRM5
* NPC ESP disabled
* Intel ESP disabled
* recoil reverted
* fixed

# RU
* fixed
```
### Update 01/05/23
```markdown
# AR2
* added back melee aura
* increased dist limit
* misc changes

# BB
* new get closest target function (need tests)
* fixed for newest bb version
* misc changes

# Drawing
* misc changes

# Physics
* misc changes
```
### Update 14/04/23
```markdown
# AR2
* disabled melee aura (detected)

# Global
* refactored utilities module
+ new move to dir function (new fly control system)
```
### Update 01/04/23
```markdown
# AR2
* fixed silent aim issues
+ new prediction module

# Bad Business (trash game lmfao)
+ new prediction module
+ no more bans (only crashes sorry)
* optimized some things

# TWR
* aimbot/silent aim fixed?

# Global
* other minor fixes
```
### Update 23/03/23
```markdown
# AR2
+ added teleport
+ walkspeed method updated
+ jumppower method updated
+ added no fall check for jumppower
+ added fast respawn
+ added respawn button
+ added play dead
+ added zombie melee aura
+ added player melee aura
+ added instant reload
+ added silent wallbang (magic bullet)
* fixed lighting section not showing

* and other misc changes
# Universal
+ new silent aim modes
* made silent aim modes toggable
* fixed lighting section not showing
# Global
+ added copy lua invite and copy json invite (server jobid)
+ new bodyparts and priority system
- removed dynamic fov (useless)
+ new trigger bot
# ESP
+ made boxes static size
+ added support for ar2 health
* fixed health check issue
# UI
+ added disabletoggle value for toggle keybind

(this is not full changelog cuz theres much more under the hood)
(this update is not actually finished but i decided to release it now because the script hasn't been updated for a long time)
```
### Update 09/03/23
```markdown
# Global
* loader changes
* loadstring changes
* drawing changes (fps fix attempt)

# BRM5
* aim function work changes (fps fix attempt)
* attempt to fix not esp'ed npcs

# Bad Business
* updated for latest game version
* viewmodel now hides with thirdperson enabled
* redeem codes now hides claimed frame faster after all redeems
* you can set transparency to 0 for weapon and arms now
* you no longer have flying state when autoshoot enabled (test)
* silent aim unpatched i guess (was banning you for 999999999 days)
* auto firemode flag changed
```
### Update 04/03/23
```markdown
# Global
* changed name of highlights to chams
* changed visual tab layout a bit
+ added chams occluded toggle (basically wallcheck)

# BRM5
* updated teleport locations

# Bad Business
* bullet tracers now works everywhere
* autoshoot unpatched i guess (was banning you for 999999999 days)

*(report if any of this doesn't work)*
```
### Update 27/02/23
```markdown
# Global
* new custom cursor (uses image)
* bunch of config flags changed so some element values may reset
* loadstring changed (should be final decision)
* changed 'misc' section to 'other'

# BRM5
+ added keybinds to vehicle and heli toggles

# Bad Business
* loading speed should be faster now
* tweaked bullet tracer to spawn little bit off the camera
* almost all tabs are rethought (thanks to Tabby @ discord server)
* tweaks to autoshoot and all of its components (grenade tp, knife aura etc)
+ added redeem codes
```
### Update 25/02/23
```markdown
# Global
* changed loader and script autoload
+ new loadstring (subject to change in future maybe)
# The Wild West
* little changes to legendary and thunderstruck esp
# BRM5
+ added intel esp
* updated teleport locations a bit
# Bad Business
+ added new hit sounds
* new anti-aim's
+ added keybind to noclip
* hitsound's section little update
```
### Update 23/02/23
```markdown
# UI
* small fixes (colorpicker and dropdown)
# Global
* updated settings tab (now its options tab)
# Bad Business
+ added thirdperson load outfit toggle
+ added character customization for thirdperson
* changed how fly works
+ added thirdperson fov slider
+ added body manipulation (now you can adjust angles of your character)

*some configs might not work with new update, srry*
```
### Update 18/02/23
```markdown
# UI
another big update for UI
* made dropdowns scrollable
* new configs autoload system
(now configs that you set to autoload will remain in game where you set it)
* other small fixes and refactors
# Global
* main theme changed to default one (Christmas theme ended)
```
### Update 17/02/23
```markdown
# Global
* fixed healthbars
* fixed distance incorrectness
# Bad Business
+ added thirdperson
```
### Update 11/02/23
```markdown
# Global
* esp module updated (configs may be corrupted)
+ added tracer outline to esp
# ST
* fixed (kind of cuz xray seems to not work)
# Bad Business
+ added hitsounds
+ added beam to autoshoot
+ added hitmarker toggle for autoshoot
+ added auto grenade
+ added grenade tp
+ changed weapon mod a bit
+ changed autoshoot section
```
### Update 01/02/23
```markdown
# AR2
* fixed zombie wont add to esp when spawned
# Bad Business
* updated autoshoot
```
### Update 29/01/23
```markdown
# AR2
* added more zombie types to zombie list
# Bad Business
* *updated for latest game version* bruh
* Remade Anti-Aim
* fixed weapon customization spamming error when match ended
* improved autoshoot now it shoots faster and fixed reloading
* fixed aimbot and etc spamming error when character not loaded
+ added grenade silent aim (testing)
* fixed weapon mod spamming errors when some things doesn't exist
# Universal
* fixed and updated findpartonray/withwhitelist/withignorelist
* raycast ray length now is 5000 instead of 1000 (silent aim)
```
### Update 27/01/23
```markdown
# Global
* fixed healthbars
* improved noclip (ar2, brm5)

# AR2
* now you can choose zombie levels in esp
```
### Update 20-23/01/23
```markdown
# Global
* Aimbot,Silent,Trigger various changes
* Prediction various changes
* from meters to studs (again)
* little optimization
# AR2
- Kill aura disabled
- removed christmas random events
* fixed prediction errors
# UI
* snowflakes will remain until feb.
* changed syn x only message a bit
```
### Update 06/01/23
```markdown
# Other
* Updated Settings tab
* tiny improvement on lighting section
# UI
* Fixed keybind setting entire keyboard instead of key (LOOL)
```
### Update 05/01/23
```markdown
# Huge UI Update
* changed how load config works
* heavy refactor of dropdown
* changed element setters
view wiki example for more info how things work now
```
### Update 04/01/23
```markdown
# AR2
* Improved Prediction
* Jump now not decreasing hunger and thrist when spoof scs enabled
# BB
* Changed config flags (update your configs)
* Improved Prediction
* some code improvements (might affect free exploits in good way)
# BRM5
+ Added support for squads in teamcheck (finally)
* Improved Prediction
```
### Update 30-31/12/22
```markdown
# Global
* fixed open on load little flickering on load (bruh)
# Steel Titans
* Changed how fly works a bit
+ Added XRay (shows enemy and friendly tanks modules)
# UI
* extended time for snowflakes and increased rate of particles per sec (snowflakes will remain until february)
* changed config section a bit + fixed some bugs related to config section
```
### Update 24-30/12/22
```markdown
# Universal
* Improvements to universal silent aim
# RU
* new more powerful silent aim
+ added prediction to every aimbot type (silent, aimbot, trigger)
# AR2
* changed ui key to period
# BB
* improved autoshoot and knife aura (part of autoshoot)
# Drawing
* various optimizations
# UI
* Added snowflakes to background (enables every december)
* fixes and other things
```
### Update 23/12/22
```markdown
# AR2
* Fixed no spread
+ Added no camera flinch
+ Added Zombie kill aura
* now synapse x only
```
### Update 22/12/22
```markdown
# BB & AR2 & BRM5
* Fixed Prediction now actually should predict
# AR2
+ Added back no spread (need tests)
```
### Update 20/12/22
```markdown
# Global
* Some attempts to increase fps once again
# BB
* now synapse x only
```
### Update 19/12/22
```markdown
# AR2
* Fixed for latest update
+ Added new Random Events
* Some attempts to increase fps for potato pc's
```
### Update 18/12/22
```markdown
# AR2
* Fixed Wallcheck
* Fixed random itemesp errors in console
+ Added some new random events
```
### Update 17/12/22
```markdown
# AR2
+ Added Fly
+ Added Master Toggle to Object ESP's
- Removed Spread (broken)
+ Added unlock firemodes
+ Added no gun bob to recoil section
+ Added Vehicle mods
+ Added WalkSpeed changer
+ Added JumpPower changer
+ Added equip in water,air,vehicle (equip in vehicle a bit buggy)
+ Added Instant Search
**SOME FLAGS CHANGED IF YOU HAD OLD CONFIGS PLEASE DELETE OR UPDATE THEM**

# Drawing
* Attempt to fix *white square*
# Global
* UI Code Small Refactor
* Some Misc Improvements/Refactor
* Improved Lighting changer (available in universal and ar2)
# BRM5
+ Added Unlock FPS
```
### Update 04/12/22
```markdown
# BRM5
* Fixed Wallcheck
* Small improvements
```
### Update 03/12/22
```markdown
# BRM5
* Changed Fog Density default value to default game value
* Fixed Unlock camera error when no character
* improved wallcheck (now uses game raycast folder)
* Fixed speedhack viewmodel getting crazy
* Improved Environment section (now more smooth and less fps hungry i guess)
```
### Update 02/12/22
```markdown
# Global
+ Made background slightly transparent
# BRM5
* Changed how Recoil slider works a bit
* Refactor and improvements to No bob, firemodes, no bullet drop
```
### Update 01/12/22
```markdown
# Global
+ Added Christmas Theme
# Those Who Remain
* Fixed Unlimited Ammo for Hammer and 50 Cal.
* Made Unlimited Ammo into Unlimiter Mag and Pool
- Disabled unnecessary inf ammo bypasses
# Bad Business
* Bumped game version (no more warning until new update)
# UI
* Fixed Dropdown Flags not being autoassigned
```
### Update 22/11/22
```markdown
- halloween disabled
* fixed background scale always 296
```
### Update 29/10/22
```markdown
# BB
- antikick disabled
# AR2
- Wallcheck disabled
- prediction disabled
# ESP
* optimizations / refactor
# loader
* refactor
```
### Update 15/10/22
```markdown
# BRM5
* fixed npc esp and aimbot
* improved teleports
* misc fixes
```
### Update 7/10/22
```markdown
# BRM5
* NPC ESP should be fixed as well as esp oov arrows
```
### Update 1/10/22
```markdown
# Global
+ Halloween Theme
# Loader
* Fixes/Improvements
```
### Update 24/08/22
```markdown
# Bad Business
* made version supported
# AR2
+ added fly (buggy and shit)
# Loader
* fixed script not loading on teleport
# BRM5
* A-10 "Enabled" renamed to "Speed Enabled" for more clarity
```
### Update 06/08/22
```markdown
# BB
* Unpatched (check announcements for *funi* video)
# BRM5
* Fixed ESP TeamCheck
# AR2
* NoClip should be fixed??
```
### Update 30/07/22
```markdown
# BRM5
* Improved Teleports (see video below)
+ Added No Clip (just like in AR2)
```
### Update 29/07/22
```markdown
#BB
* Version Bump (nothing changed)
#AR2
* Container ESP Fix
# BRM5
* Silent Aim Fix
# Global
* Wallcheck Fix
```
### Update 29/07/22
```markdown
# AR2
+ Collapse Container things example: M1911 (x2)
+ Special section for Random Places
+ Miniboss ESP
+ Vehicles ESP
+ Noclip
+ Anti-Zombie
+ Silent Aim
+ No Spread
+ Prediction
+ Add Keybinds
# BRM5
+ Target Mode to NPC Mode
# RU
* Improve Silent Aim
# Global
* Distance Check Fix
+ Distance Check Toggle
# Universal
+ Mouse.Hit / Mouse.Target Silent Aim Support
# Drawing
+ Outline Arrows
+ Outline Head
+ Healthbar
+ Circle Outline
+ Optimize ESP
```
### Update 23/07/22
```markdown
# AR2
+ Added No Fall Impact
+ Added No Jump Delay
+ Added Always Run
+ Added Spoof SCS (SCS - Set Character State: No Fall Damage, Less Hunger / Thirst While Sprinting)
* Improved Container ESP
```
### Update 23/07/22
```markdown
# AR2
+ Fixed Random Places ESP (causing script not work at all)
+ Added new places to Random Places ESP
* Changed Notification for Random Places ESP
* Improved Container ESP
# UI
* Improved Notification2 function
```
### Update 21/07/22
```markdown
# AR2
+ Added Random Places ESP
+ Added Map ESP
* Improved Wallcheck
# BRM5
* Changed Teleport Positions
# The Wild West
* Changed Animal and Tree ESP
# Global
+ Added Distance to ESP and Combat
* Switched from studs to meters
# UI
* Fixed Dropdown size with big lists
* Cleared some code
```
### Update 20/07/22
```markdown
# AR2
* Item ESP tab reworked
+ Added Container ESP
```
### Update 16/07/22
```markdown
# Bad Business
+ added warning for unsupported game version
+ added hitmarkers to autoshoot and silent aim
* improved autoshoot, now it works with shotguns
+ added infinity ammo to autoshoot
# Global
* changed game tab to "Miscellaneous" tab
```
### Update 15/07/22
```markdown
# ST
* unpatched fly
# AR2
* Added loot esp (not container esp)
# global
* changed some things
```
### Update 12/07/22
```markdown
# Bad Business
+ unpatched
# Global
* ESP Optimization
* fixed trigger bot weird keybind bug
```
### Update 12/07/22
```markdown
# Bad Business
+ added more protection from ban
* improved autoshoot now it shoots on long distances with cost of wait time (bullet drop)
# Loader
* Loader has been rewritten, now it only loads one script for your game, and not all scripts
# Those Who Remain
* Rename no bullet drop to instant hit (read tooltips for more info)
# Universal
* fixed globalshadows not working in lighting changer
# AR2
+ Released
+ Added no recoil and lighting changer for now
- Silent Aim disabled due to ban risk :shrug:
```
### Update 09/07/22
```markdown
# Bad Business
* unpatched (use alts cuz i am unsure)
# Those Who Remain
+ Added Unlimited Ammo
+ Added Wallbang (Works only with Silent Aim)
+ Added No Bullet Drop (Works only with Silent Aim)
# Global
- Removed unused prints for debug
```
### Update 05/07/22
```markdown
# BRM5
+ Added A-10 Custom Fly
+ Added A-10 Speed Changer
+ Added A-10 ThirdPerson Camera
+ Added A-10 Auto Start Engines Button
+ Added Trigger RMB Mode
* Fixed Network Bug
* Other Fixes
# Bad Business
* Fixed Minimap Bug
# Those Who Remain
+ Released (Silent Aim, Aimbot, ESP)
# Global
* Some Optimizations
* Improved Trigger
```
### Update 26/06/22
```markdown
# Bad Business
* unpatched
(they really thinking that removing print("ouch") could stop me? lmao)
```
### Update 25/06/22
```markdown
+ made some optimization go check if its still lags for you
```
### Update 25/06/22
```markdown
# Bad Business
* unpatched
(it was little bit hard but i did it)
```
### Update 22/06/22
```markdown
# BRM5
+ added anti fall
+ added teleports (thanks to MARCO POLO#3842 for tp method)
+ added force character reset
* fixed custom mouse disabled by default
```
### Update 19/06/22
```markdown
# Universal
+ added blur gameplay in settings
+ bring back Close On Exec (now named Open On Load)
```
### Update 10/06/22
```markdown
# BRM5
* fixed getconnections for shitsploits
* fixed nvg shape
```
### Update 10/06/22
```markdown
# Bad Business
* fixed prediction with magic book (finally)
```
### Update 03/06/22
```markdown
+ Added Steel Titans (Fly and ESP)
# BRM5
+ Added Fake RGE
* Fixed HookFunction Typo
```
### Update 29/05/22
```markdown
# Bad Business
+ added Fly No Clip
+ added Lean Random Anti Aim
* changed trigger bot shoot func a bit
# Universal (All Games)
* changed how server hop, rejoin and join discord server buttons work (tell me if they dont work)
# The Wild West
- disabled most of functions cuz they can be detected
(gonna leave it like this until i figure out how anti cheat works)
```
### Update 28/05/22
```markdown
# Bad Business
* fixed autoshoot for new game version
* improved autoshoot a bit
* made autoshoot use actual weapon config (more precise reloading time)
```
### Update 26/05/22
```markdown
# Bad Business
+ addded anti-kick
+ added 360 mode for autoshoot
* autoshoot improved
* bad business tab relayout
# RAGDOLL UNIVERSE
* fixed esp
```
### Update 21/05/22
```markdown
* fixes
+ Added TWW
```
### Update 16/05/22
```markdown
# BRM5
+ added no nvg shape
* you can change recoil percent now
* code now a lot smaller
```
### Update 15/05/22
```markdown
# Bad Business
* changed anticheat resolver (thx kiriot :) )
* changed and fixed autoshoot (more stable i guess?)
* made gravity correction dynamic again, but looks like it doesnt affect prediction at all
```
### Update 15/05/22
```markdown
# Bad Business
* ez fix lmao, their methods suck
```
### Update 14/05/22
```markdown
# Bad Business
* made gravity correction static cuz its breaking whole script for some reason
```
### Update 14/05/22
```markdown
# Bad Business
* fixed gravity prediction
* fixed velocity prediction
* fixed gravity correction
* update for trigger bot
# Universal
- removed lighting cuz buggy and shit overall
* changed dynamic fov
* something changed, cant remember what so find out what i changed for yourself :)
```
### Update 08/05/22
```markdown
* Bug Fixes
* Watermark Changed
```
### Update 07/05/22
```markdown
# Bad Business
* Fixed Silent Aim Priority
# Global
* Box Improvements
```
### Update 00/05/22
```markdown
# Global
+ Font picker
* ESP remade to Flags
* Revert Watermark and make it draggable and you can save position
+ lighting controls in visuals tab
```
### Update 30/04/22
```markdown
# Global
* watermark now uses drawing lib
# Bad Business
* Fixed silent aim uses settings from aimbot (lol)
```
### Update 27/04/22
```markdown
# Global
+ New Config System
```
### Update 15/04/22
```markdown
# BRM5
* Fixed ESP (now civilians green)
# Global
+ Added Dynamic FOV (changes with your camera FOV)
```
### Update 14/04/22
```markdown
# Bad Business
+ added bullet drop correction to prediction (not 100% precise)
```
### Update 13/04/22
```markdown
# Bad Business
+ Weapon Modifications now less laggy (but you need respawn every time you change something)
# BRM5
* Attempt to fix ESP lags
* Prediction now auto detects bullet velocity
```
### Update 12/04/22
```markdown
# Bad Business
+ Added Bullet Drop Changer
* Changed Trigger Bot
```
### Update 11/04/22
```markdown
# BRM5
* NPC ESP Changed
+ Added no NVG Goggles Effect
```
### Update 10/04/22
```markdown
# Bad Business
+ Camera Modifications
* Changed AutoShoot
# BRM5
* Fixed
```
