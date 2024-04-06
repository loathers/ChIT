# Character Info Toolbox

Character Info Toolbox (ChIT for short) is a character pane relay override script for [KoLMafia](https://github.com/kolmafia/kolmafia).

# Installation

Run this command in the graphical CLI:

```
git checkout https://github.com/Loathing-Associates-Scripting-Society/ChIT.git
```

Will require [a recent build of KoLMafia](https://ci.kolmafia.us/job/Kolmafia/lastSuccessfulBuild/).

### Migrating from SVN to Git

With Mafia support now implemented for git you can now remove the old SVN repo and convert to git.

```
svn delete Loathing-Associates-Scripting-Society-ChIT-branches-main-src
```

Then install ChIT as normal.

## Uninstallation

Run this command in the graphical CLI:
```
git delete ChIT
```
note that the above command is case sensitive. `chit` will not work it has to be `ChIT`

## What if I already have the sourceforge version installed?

If you are switching from the old sourceforge version of ChIT, run this command before the previous command:

```
svn delete mafiachit
```

If you have done any configuration of ChIT on the old version, don't worry!
Your settings will carry over automatically.

### A Small Warning

Once you switch to the Github version of ChIT, if you switch back to the Sourceforge version for some reason,
all of your boolean preferences will get messed up. Not that there's really any reason to switch back in the
first place regardless.

# Examples

Here are some very old examples of what ChIT can make your charpane look like, compared against the default charpane.

![Chit Examples](chitpanels.png)

Here's what my personal (heavily customized) charpane looks like at the moment (in the Dark Gyffte path):

![Soolar's Charpane](soolarpanel.png)

If you've customized your charpane, please by all means send me a screenshot to include here!

# Settings

## How Settings Work

You can override the default by making a character specific setting with the set command in the CLI. Examples:

- set chit.clan.home = Hardcore Nation
- set chit.stats.layout = muscle,myst,moxie|hp,mp,axel|mcd|terminal|trail,florist
- enter `prefref chit.` in the CLI to see a list of all properties and their current values
  - Most settings in the prefref will be set to "DEFAULT:\[default]" by default.
    As long as DEFAULT remains at the start, the setting will automatically update with any
    changes to the default value.
    The part after the colon exists only to tell you what the default is, to make `prefref chit.` more useful.
  - If a setting matches the default but lacks the "DEFAULT:" prefix, it will be restored.
    - If you want to make sure it doesn't get updated in the future, you can set it to "NONDEFAULT:\[value]".

## Layout Settings

CHIT allows you to customize the layout of your charpane (Let's call it your House).

Your house consists of 4 separate areas:

- Roof: Always anchored to the top of the screen
- Walls: Scrollable area between the roof and the floor
- Floor: Always anchored to the bottom of the screen, and always contains the Toolbar as the last item
- Toolbar: Row of pretty icons that does various things

### Bricks

Inside each area you can place any of the following "bricks":

- character: Basic character information (name, class, paths, level, meat, turns etc) (Not available in toolbar)
- stats: A whole bunch of pretty progress bars. (stats/consumption/hp/mp etc) (Not available in toolbar)
- familiar: Familiar information, with a built-in equipment changer thingy (Not available in toolbar)
- gear: Displays all your currently equipped items, and allows you to pick from favorites/suggestion by clicking a slot.
- trail: Recent adventures
- quests: Quest nudges (when available)
- tracker: Detailed ascension related quest information
- helpers: Adventure helpers (described in more detail below)
- thrall: Displays current Pasta Thrall, if you are a Pastamancer
- robo: Provides an interface to reassemble yourself in the path You, Robot
- vykea: Displays current VYKEA companion, if you have one
- horsery: Displays your current horse, and allows you to conveniently switch
- boombox: Displays your boombox setting, and allows you to conveniently switch
- terminal: Displays your source terminal skills and allows you to swap them (not available for the toolbar, not recommended for the floor)
- effects: List of current effects (Not available in toolbar)
- organs: similar to stats, but only shows spleen, stomach and liver (more useful when used in the toolbar)
- substats: similar to stats, but only shows muscle,myst and moxie (more useful when used in the toolbar)
- modifiers: Some useful modifiers (+meat, +items, +combat, ML, DA, DR etc)
- elements: Shows the KoL elements chart from the wiki (also mostly for the toolbar)
- update: Notifies you when new versions of CHIT are available
- next: Provides a dropdown to tell ChIT where you're going next to get recommendations beforehand

### Layout Variables

So how do you design and build your own house? Easy.
Simply place your bricks in the area you want, in the order you want them.

- chit.roof.layout: List of bricks to place in your roof
  - Default: character,stats,gear
- chit.walls.layout: List of bricks to place in your walls
  - Default: helpers,thrall,robo,vykea,effects,horsery,boombox
- chit.floor.layout: List of bricks to place in your floor
  - Default: update,familiar
- chit.toolbar.layout: Comma-separated list of bricks to place in the toolbar
  - Special values:
    - disable - a brick you can add here which is actually a small button to disable ChIT.
  - Default: trail,quests,modifiers,elements,organs

The roof, walls and floor of your house can use some special syntax to lay bricks out in rows and columns.
- | separator places bricks or groups of bricks horizontally adjacent each other in a row
- , separator starts a new row of bricks after the previous row
- ( ) parens vertically group bricks
- { } curly braces horizontally group bricks

Overriding the width of a brick or group of bricks can be accomplished by adding the following suffix immediately after it:
- :X% sets its width to X%.
- :Xpx sets its width equal to X pixels.
- :X\* sets its width to be X times wider than the default width of bricks in that row.

If no width override is supplied, ChIT tries to make all bricks in the same row the same width, content allowing.

examples:
- character|gear:112px,stats:3\*|(familiar,trail):2\*
- effects:2\*|(trail,gear,familiar,boombox)

Each brick may have an icon at the top left in it's title bar.
When the icon is clicked, the contents of the walls will (temporarily) "stretch" over the roof space.
Click a brick icon again (any one will do) to restore your view of the roof.
The roof will also be restored on any reload of the character pane.

### Brick Variables

The following preferences further refine the content and appearance of individual bricks

- chit.character.avatar: Shows or hides your character image (true/false)
  - Default: true
- chit.character.title: Shows your Custom Title if you have one, instead of your current class name. (true/false)

  - It might be useful to disable this if you have a long title that causes ugly wrapping in the charpane.
  - Default: true

- chit.stats.layout: Your stats can be further customized with another comma-separated list
  - Commas can be replaced by pipe characters (|) to add some visual seperation between different elements
  - mainstat,moxie,myst,muscle - substat progress
  - liver,stomach,spleen - color-coded progress bars for consumption
  - hp,mp - progress bars are clickable to restore HP/MP (if enabled in mafia)
  - axel - that creepy spooky little girl from the spaaaaace quest (only while doing the quest)
  - mcd - the progress bar is clickable to let you set a new value
  - trail - last adventure
  - florist - shows Florist Friars plants for current location, if you have access to it
  - Default: muscle,myst,moxie|hp,mp,axel|mcd|trail,florist
- chit.stats.showbars: Shows or hides progress bars

  - Default: true

- chit.quests.hide: Don't display Quest Nudges when you don't have any active quests (true/false)

  - Default: false (standard KoL behaviour)

- chit.familiar.hats: Vertical bar (|) separated list of hats to include with a Hatrack as your current familiar
  - Default: spangly sombrero|sugar chapeau
- chit.familiar.weapons: Vertical bar (|) separated list of weapons to include with a Disembodied Hand as your current familiar
  - Default: time sword|batblade|Hodgman's whackin' stick|astral mace|Maxwell's Silver Hammer|goatskin umbrella
- chit.familiar.pants: Vertical bar (|) separated list of pants to include with a Fancypants Scarecrow as your current familiar
  - Default: spangly mariachi pants|double-ice britches|BRICKO pants|pin-stripe slacks|Studded leather boxer shorts|Monster pants|Sugar shorts
- chit.familiar.off-hands: Vertical bar (|) separated list of off-hands to include with a Left-Hand Man as your current familiar
  - Default: Kramco Sausage-o-Matic&trade;|latte lovers member's mug|A Light that Never Goes Out|Half a Purse
- chit.familiar.protect: Removes all familiar-switching links from the charpane when you're on a 100% run
  - (You have to go to your campsite->terraium to change familiars, or use chat commands)
  - Default: false
- chit.familiar.anti-gollywog: Colorize the Crimbo Shrub's image so that it doesn't look like a gollywog
  - Default: true
- chit.familiar.hiddengear: Comma delimited list of generic familiar equipment to hide from the familiar gear picker.
  - Default:
- chit.familiar.iconize-weirdos: Should we display familiars like melodramedary as their hatchling images instead?

  - Default: false

- chit.gear.favorites: Vertical bar (|) separated list of equipment that you have set as a personal favorite.
  - You can change this all you should need to via the gear picker, so you shouldn't edit this one manually.
  - Empty by default
- chit.gear.layout: The layout to use for the gear picker.
  - Options include:
    - default - The standard layout
    - minimal - Only shows gear icons. left click to equip/make/pull/whatever, right click for description popup.
    - oldschool - The old layout style that gave every item an entire row. Might be good if your charpane is pretty narrow.
  - Default: default
- chit.gear.display.in-run: Comma delimited list of categories to display in the gear picker while in-run, in order
  - Valid categories are:
    - favorites - gear from chit.gear.favorites
    - astral - astral equipment from valhalla
    - item - gear that gives a +item drop bonus
    - meat - gear that gives a +meat drop bonus
    - -combat - gear that makes monsters less attracted to you
    - +combat - gear that makes monsters more attracted to you
    - ML - gear that gives +ML
    - exp - gear that gives general +substats or main +substats
    - quest - gear needed for certain quests
    - path - gear that is particularly useful in your current path
    - prismatic - gear with prismatic elemental damage
    - elemental - gear with any elemental damage at all
    - res - gear with a significant total amount of elemental resistance
    - resistance - gear with any elemental resistance at all
    - fam weight - gear with +familiar weight
    - mainstat - +mainstat gear
    - muscle - +muscle gear
    - myticality - +myst gear
    - moxie - +mox gear
    - melee damage - damage with melee weapons
    - spell damage - damage with spells, not including elemental spell damage
    - ranged damage - damage with ranged weapons
    - damage - melee damage/spell damage/ranged damage for muscle/myst/moxie classes respectively
    - hp regen - gear with hp regen
    - mp regen - gear with mp regen
    - max hp - +max hp gear
    - max mp - +max mp gear
    - initiative - +init gear
    - smithsness - +smithsness gear
    - charter - gear for charter quests or other charter related tasks
    - today - gear that will disappear at the end of the day
    - rollover - gear with +adv (and +fites if your hippy stone is broken), will only display when overdrunk
    - DRUNK - just Drunkula's wineglass, will only display when overdrunk
    - Wow - World's best adventurer?! Wow! Good for you! A+!
  - Category names ARE case sensitive. The list is comma delimited.
  - You can also create your own custom categories, by editting data/chit_GearCategories.txt
  - Explanation of how to do so is provided via comments in data/chit_GearCategories.txt
  - Certain special categories that are too niche to include will always be displayed (ex. bounty is basically just the fledges or the talisman o' namsilat when needed for bounty hunting)
  - You can include some options with a category by appending a : and then \[option]=\[value]
  - Valid options are:
    - amount=(any numeric value, or "all"): how many items to display in this category (from best to worst, when applicable). "all" "0" or any negative number will just display everything.
    - pull=(true/false): whether to display items in this category when you only have them in Hagnk's and have pulls left
    - create=(true/false): whether to display items when you could make them but don't have any made
  - When these options are not explicitly provided for a category, the defaults are decided by chit.gear.display.in-run.defaults
  - Default: favorites:amount=all:pull=true:create=true, astral:amount=all, item, -combat, +combat, quest:amount=all:pull=true:create=true, today:amount=all:create=false, ML, path:amount=all, prismatic, res, resistance:amount=2, charter:amount=all, rollover, DRUNK:amount=all, Wow:amount=all, exp
- chit.gear.display.in-run.defaults: The default values for the options in chit.gear.display.in-run when not provided
  - Follows the same rules as the valid options section listed above in chit.gear.display.in-run
  - Default: create=false, pull=false, amount=all
- chit.gear.display.aftercore: Same as chit.gear.display.in-run, but shown in aftercore instead of in-run
  - Default: favorites:amount=all, quest:amount=all, charter:amount=all, today:amount=all:create=false, rollover, DRUNK:amount=all
- chit.gear.display.aftercore.defaults: Same as chit.gear.display.in-run.defaults, but for aftercore
  - Default: create=true, pull=true, amount=1
- chit.gear.ignoreG-Lover: Whether or not to avoid hiding G-less gear in G-Lover
  - With this set to false, only quest items without G's will be recommended
  - Default: false
- chit.gear.lattereminder: Whether to warn when not using latte and a latte unlock is available
- chit.gear.ccswordcanereminder: Whether to warn when not using candy cane sword cane and an important use is available

  - With this set to true, if you are adventuring in a zone where a latte unlock can be acquired that you have no acquired yet (and you have a latte) all other off-hands will be highlighted in orange, except for important offhands like the UV-resistant compass and the unstable fulminate.
  - Default: true

- chit.currencies: List of currencies other than meat to display when mousing over your meat (or other active currency)
  - Default: disassembled clover|rad|hobo nickel|Freddy Kruegerand|Chroner|Beach Buck|Coinspiracy|FunFunds&trade;|Volcoino|Wal-Mart gift certificate|BACON|buffalo dime|Source essence|cop dollar|sprinkles|Spacegate Research
- chit.currencies.special: List of special case currencies to display when mousing over your meat (or other active currency)
  - Default: asdonmartinfuel
    - At the moment, asdonmartinfuel is the only such currency
- chit.currencies.showmany: Whether or not to enable showing several currencies at once
  - If this is true, clicking currencies in the dropdown list will add or remove them from the list of displayed currencies
    - Otherwise, it will simply set whatever you clicked to be the current currency
  - Default: false
- chit.currencies.showmany.choices: What currencies to presently display
  - Only relevant if chit.currencies.showmany is set to true
  - Should be a | delimited list
  - Default: meat

HELPERS are displayed when certain counters reaches 0.
They will present you with a list of relevant adventure locations.
Helpers are there merely for convenience; they will NOT try to auto-adventure for you.

- chit.helpers.wormwood: Enables or disables the Wormwood helper (triggered when the Wormwood counter reaches 0)
  - Comma-separated list of desired Wormwood goals.
    - Valid values: moxie,myst,muscle,pipe,booze,food,mask,cancan,necklace
    - A reasonable effort is made to figure out what you mean for other values (eg. "spleen" or "flask" will also work)
  - Special values:
    - none (or blank) - disables the helper
    - mainstat - chooses stat adventures based on your current class
    - stats - shorthand for all stats
    - rewards - shorthand for all consumable/equipment rewards
  - For stat rewards, you can also append a 1,5 or 9 to determine when the helper is triggered
    - Examples:
      - mainstat5 - shows locations for you mainstat reward with A-M at 5/1
      - mainstat,stats1 - shows mainstat reward with A-M at 9/5/1, and all 3 stat rewards with A-M at 1
      - moxie,booze - shows moxie and booze rewards
      - stats,rewards - shows every achievable reward
  - Default: stats,spleen_limit
- chit.helpers.dancecard: Enables or disables the Dance Card helper (triggered when the DC counter reaches 0)
  - true - enabled (default)
  - false - disabled
- chit.helpers.semirare: Enables or disables the Semi-Rare helper (triggered when the Fortune Cookie counter reaches 0)
  - true - enabled (default)
  - false - disabled
- chit.helpers.spookyraven: Enables or disables information about Lights Out adventures in Spookyraven Manor
  - true - enabled (default)
  - false - disabled
- chit.helpers.xiblaxian: Enables or disables the Xiblaxian materials counter when you are wearing a Xiblaxian holo-wrist-puter

  - true - enabled (default)
  - false - disabled

- chit.effects.classicons: Replaces effect icons with class-specific icons
  - Comma-separated list of classes to replace
  - none - does nothing (default)
  - sc - replace SC buffs with a seal club
  - tt - replace TT buff icons with a turtle
  - pm - replace PM buff icons with a pasta spoon
  - sa - replace SA buff icons with a saucepan
  - db - replace DB buff icons with a disco ball
  - at - replace AT buff icons with an accordion (useful in conjunction with chit_bumpsongs)
  - Example: tt,at - replaces only TT and AT buffs
- chit.effects.showicons: Shows effect icons, or doesn't (compact-style)
  - true - show them (default)
  - false - don't show them
- chit.effects.modicons: Allows icons for effects to be modified. This is mostly used to differential timers.
  - Default: true
- chit.effects.layout: Comma-separated list
  - buffs - regular effects
  - intrinsics - intrinsic effects
  - songs - only if present, this will cause all active AT songs to be displayed separately. (And other limited quantity buffs like Boris and Jarlsberg)
  - advmods - Adventure Modifiers (currently just non-combat forcers)
  - Example:
    - intrinsics,limited,buffs - displays intrinsic effects first, then any AT songs, then all other effects/buffs
  - Default: advmods,songs,buffs,intrinsics
- chit.effects.usermap: Allows you to use personalized versions of chit_effects.txt
  - true: uses chit_effects\_\[yourname].txt
  - false: uses chit_effects.txt (default)
- chit.effects.describe: Adds descriptions for each active effect.

  - Default: true

- chit.thrall.showname: If true, shows the thrall name instead of type on the thrall brick

  - Default: false

- chit.toolbar.moods: Shows or hides toolbar icon from changing and executing moods

  - bonus: shows two icons, one for changing and the other for executing
  - false: Does not show either
  - Default: true -- shows one icon to change and execute moods

- chit.kol.coolimages: Shows or hides KoL's images for Extreme Meter and Zombie Horde

  - Default: true

- chit.next.maxlen: The next brick will shorten location names that are longer than this limit in its dropdown. Full location name can still be seen on mouseover when shortened. A value of 0 means no limit.

  - Default: 30

- chit.disable: If this is set true, then chit will be disabled

  - Default: false

- chit.autoscroll: Remembers the scroll of your walls when the charpane refreshes (true/false)
  - Default: true

# Credits

- Primary Maintainer: [soolar](https://github.com/soolar)
- Other Maintainers: [ckb11](https://github.com/ckb11) (ckb on the KoLMafia forums)
  and [tyrion-the-imp](https://github.com/tyrion-the-imp) (AlbinoRhino on the KoLMafia forums)
- Original Author: Chez
- Previous Primary Maintainer: Bale

## Historical Credits

By Chez up to v 0.6.0 -- All hail Chez! After that a bunch of people assumed control.

Chez offers many thanks to:

- Zarqon, for his zlib library
- Bale, from whose CounterChecker script I stole some ideas and code
- All the countless KoLMafia devs and contributors, whose work make all our little pet projects possible
- Ereinion and Caprosmaster, for helping with initial testing and feedback
- Icons from http://www.famfamfam.com/lab/icons/silk/ & https://www.flaticon.com/

Bale also wants to offer thanks to:

- AlbinoRhino who has helped me with javascript, html and css when it exceeded my ability
- ckb who wrote the tracker brick and added display and parsing for effects descriptions
- soolar who wrote the amazing gear Brick
- Many other people who have inspired and assisted me in with this project in ways that are hard to quantify
