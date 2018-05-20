CHaracter Info Toolbox: A character pane relay override script
By Chez up to v 0.6.0 -- All hail Chez! After that a bunch of people assumed control.

**************************************
How do I edit the following settings?

1. You can edit their default values by editing them at the top of \svn\mafiachit\relay\charpane.ash
   To propogate those changes to the working copy you then enter the following command in the gCLI tab: svn sync
   Defaults are used for all characters unless a preference is set for a specific character by the following method.
2. You can override the default by making a character specific setting with the set command in the CLI. Examples:
   set chit.clan.home = Hardcore Nation
   set chit.stats.layout = muscle,myst,moxie|hp,mp,axel|mcd|terminal|trail,florist
   enter "prefref chit" in the CLI to see a list of all properties and their current values
**************************************

CHIT allows you to customize the layout of your charpane (Let's call it your House).
Your house consists of 4 separate areas:
   Roof:       Always anchored to the top of the screen
   Walls:      Scrollable area between the roof and the floor
   Floor:      Always anchored to the bottom of the screen, and always contains the Toolbar as the last item
   Toolbar:    Row of pretty icons that does various things

Inside each area you can place any of the following "bricks":
   character:  Basic character information (name, class, paths, level, meat, turns etc) (Not available in toolbar)
   stats:      A whole bunch of pretty progress bars. (stats/consumption/hp/mp etc) (Not available in toolbar)
   familiar:   Familiar information, with a built-in equipment changer thingy (Not available in toolbar)
   gear:       Displays all your currently equipped items, and allows you to pick from favorites/suggestion by clicking a slot.
   trail:      Recent adventures
   quests:     Quest nudges (when available)
   tracker:    Detailed ascension related quest information
   helpers:    Adventure helpers (described in more detail below)
   thrall:     Displays current Pasta Thrall, if you are a Pastamancer
   vykea:      Displays current VYKEA companion, if you have one
   horsery:    Displays your current horse, and allows you to conveniently switch 
   terminal:   Displays your source terminal skills and allows you to swap them (not available for the toolbar, not recommended for the floor)
   effects:    List of current effects (Not available in toolbar)
   organs:     similar to stats, but only shows spleen, stomach and liver (more useful when used in the toolbar)
   substats:   similar to stats, but only shows muscle,myst and moxie (more useful when used in the toolbar)
   modifiers:  Some useful modifiers (+meat, +items, +combat, ML, DA, DR etc)
   elements:   Shows the KoL elements chart from the wiki (also mostly for the toolbar)
   update:     Notifies you when new versions of CHIT are available
         
So how do you design and build your own house? Easy. Simply place your bricks in the area you want, in the order you want them.
-------------------------------------------------------------------------------------
chit.roof.layout: Comma-separated list of bricks to place in your roof
   Default: character,stats,gear

chit.walls.layout: Comma-separated list of bricks to place in your walls
   Default: helpers,thrall,vykea,effects,horsery

chit.floor.layout: Comma-separated list of bricks to place in your floor
   Default: update,familiar

chit.toolbar.layout: Comma-separated list of bricks to place in the toolbar
   Special values:
      disable - a brick you can add here which is actually a small button to disable ChIT.
   Default: trail,quests,modifiers,elements,organs

*************************************************************************************
The following preferences further refine the content and appearance of individual bricks
*************************************************************************************

chit.character.avatar: Shows or hides your character image (true/false)
   Default: true
               
chit.character.title: Shows your Custom Title if you have one, instead of your current class name. (true/false)
   It might be useful to disable this if you have a long title that causes ugly wrapping in the charpane.
   Default: true
-------------------------------------------------------------------------------------
chit.stats.layout: Your stats can be further customized with another comma-separated list
   Commas can be replaced by pipe characters (|) to add some visual seperation between different elements
      mainstat,moxie,myst,muscle - substat progress
      liver,stomach,spleen - color-coded progress bars for consumption
      hp,mp - progress bars are clickable to restore HP/MP (if enabled in mafia)
      axel - that creepy spooky little girl from the spaaaaace quest (only while doing the quest)
      mcd - the progress bar is clickable to let you set a new value
      trail - last adventure
      florist - shows Florist Friars plants for current location, if you have access to it
   Default: muscle,myst,moxie|hp,mp,axel|mcd|trail,florist
chit.stats.showbars: Shows or hides progress bars
   Default: true
-------------------------------------------------------------------------------------
chit.quests.hide: Don't display Quest Nudges when you don't have any active quests (true/false)
   Default: false (standard KoL behaviour)            
-------------------------------------------------------------------------------------
chit.familiar.hats: Comma-separated list of hats to include with a Hatrack as your current familiar
   Default: spangly sombrero,sugar chapeau

chit.familiar.weapons: Comma-separated list of weapons to include with a Disembodied Hand as your current familiar
   Default: time sword,batblade,Hodgman's whackin' stick,astral mace,Maxwell's Silver Hammer,goatskin umbrella

chit.familiar.pants: Comma-separated list of pants to include with a Fancypants Scarecrow as your current familiar
   Default: spangly mariachi pants,double-ice britches,BRICKO pants,pin-stripe slacks,Studded leather boxer shorts,Monster pants,Sugar shorts

chit.familiar.protect: Removes all familiar-switching links from the charpane when you're on a 100% run
   (You have to go to your campsite->terraium to change familiars, or use chat commands)
   Default: false
chit.familiar.anti-gollywog: Colorize the Crimbo Shrub's image so that it doesn't look like a gollywog
   Default: true
chit.familiar.hiddengear: Comma delimited list of generic familiar equipment to hide from the familiar gear picker.
-------------------------------------------------------------------------------------
chit.gear.favorites: Comma-separated list of equipment that you have set as a personal favorite.
   You can change this all you should need to via the gear picker, so you shouldn't edit this one manually.
   Default: Just some random items I like.

chit.gear.layout: The layout to use for the gear picker.
   Options include:
      default - The standard layout
      minimal - only shows gear icons. left click to equip/make/pull/whatever, right click for description popup.
      experimental - WIP layout that should eventually become default, but might occasionally be a bit janky
   Default: default
     
chit.gear.display.in-run: Comma delimited list of categories to display in the gear picker while in-run, in order
   Valid categories are:
      favorites - gear from chit.gear.favorites
      astral - astral equipment from valhalla
      item - gear that gives a +item drop bonus
      meat - gear that gives a +meat drop bonus
      -combat - gear that makes monsters less attracted to you
      +combat - gear that makes monsters more attracted to you
      ML - gear that gives +ML
      exp - gear that gives general +substats or main +substats
      quest - gear needed for certain quests
      path - gear that is particularly useful in your current path
      prismatic - gear with prismatic elemental damage
      elemental - gear with any elemental damage at all
      res - gear with a significant total amount of elemental resistance
      resistance - gear with any elemental resistance at all
      fam weight - gear with +familiar weight
      mainstat - +mainstat gear
      muscle - +muscle gear
      myticality - +myst gear
      moxie - +mox gear
      melee damage - damage with melee weapons
      spell damage - damage with spells, not including elemental spell damage
      ranged damage - damage with ranged weapons
      damage - melee damage/spell damage/ranged damage for muscle/myst/moxie classes respectively
      hp regen - gear with hp regen
      mp regen - gear with mp regen
      max hp - +max hp gear
      max mp - +max mp gear
      initiative - +init gear
      smithsness - +smithsness gear
      charter - gear for charter quests or other charter related tasks
      today - gear that will disappear at the end of the day
      rollover - gear with +adv (and +fites if your hippy stone is broken), will only display when overdrunk
      DRUNK - just Drunkula's wineglass, will only display when overdrunk
      Wow - World's best adventurer?! Wow! Good for you! A+!
   Category names ARE case sensitive. The list is comma delimited.
   You can also create your own custom categories, by editting data/chit_GearCategories.txt
   Explanation of how to do so is provided via comments in data/chit_GearCategories.txt
   Certain special categories that are too niche to include will always be displayed (ex. bounty is basically just the fledges or the talisman o' namsilat when needed for bounty hunting)
   You can include some options with a category by appending a : and then <option>=<value>
   Valid options are:
      amount=(any numeric value, or "all"): how many items to display in this category (from best to worst, when applicable). "all" "0" or any negative number will just display everything.
      pull=(true/false): whether to display items in this category when you only have them in Hagnk's and have pulls left
      create=(true/false): whether to display items when you could make them but don't have any made
   When these options are not explicitly provided for a category, the defaults are: create=false, pull=false, amount=1
   Default: favorites:amount=all:pull=true:create=true, astral:amount=all, item, -combat, +combat, quest:amount=all:pull=true:create=true, today:amount=all:create=false, ML, path:amount=all, prismatic, res, resistance:amount=2, charter:amount=all, rollover, DRUNK:amount=all, Wow:amount=all, exp

chit.gear.display.aftercore: Same as chit.gear.display.in-run, but shown in aftercore instead of in-run
   When these options are not explicitly provided for a category, the defaults are: create=false, pull=false, amount=1
   Default: favorites:amount=all, quest:amount=all, charter:amount=all, today:amount=all:create=false, rollover, DRUNK:amount=all

chit.gear.ignoreG-Lover: Whether or not to avoid hiding G-less gear in G-Lover
   With this set to false, only quest items without G's will be recommended
   Default: false
-------------------------------------------------------------------------------------
chit.currencies: List of currencies other than meat to display when mousing over your meat (or other active currency)
   Default: disassembled clover|rad|hobo nickel|Freddy Kruegerand|Chroner|Beach Buck|Coinspiracy|FunFunds&trade;|Volcoino|Wal-Mart gift certificate|BACON|buffalo dime|Source essence|cop dollar|sprinkles|Spacegate Research
chit.currencies.special: List of special case currencies to display when mousing over your meat (or other active currency)
   Default: asdonmartinfuel
      At the moment, asdonmartinfuel is the only such currency
chit.currencies.showmany: Whether or not to enable showing several currencies at once
   If this is true, clicking currencies in the dropdown list will add or remove them from the list of displayed currencies
     Otherwise, it will simply set whatever you clicked to be the current currency
   Default: false
chit.currencies.showmany.choices: What currencies to presently display
   Only relevant if chit.currencies.showmany is set to true
   Should be a | delimited list
-------------------------------------------------------------------------------------
HELPERS are displayed when certain counters reaches 0. 
They will present you with a list of relevant adventure locations. 
Helpers are there merely for convenience; they will NOT try to auto-adventure for you.

chit.helpers.wormwood: Enables or disables the Wormwood helper (triggered when the Wormwood counter reaches 0)
   Comma-separated list of desired Wormwood goals.
      Valid values: moxie,myst,muscle,pipe,booze,food,mask,cancan,necklace
      A reasonable effort is made to figure out what you mean for other values (eg. "spleen" or "flask" will also work)
   Special values:
      none (or blank) - disables the helper
      mainstat - chooses stat adventures based on your current class
      stats - shorthand for all stats
      rewards - shorthand for all consumable/equipment rewards
   For stat rewards, you can also append a 1,5 or 9 to determine when the helper is triggered
      Examples:
         mainstat5 - shows locations for you mainstat reward with A-M at 5/1
         mainstat,stats1 - shows mainstat reward with A-M at 9/5/1, and all 3 stat rewards with A-M at 1
         moxie,booze - shows moxie and booze rewards
         stats,rewards - shows every achievable reward

chit.helpers.dancecard: Enables or disables the Dance Card helper (triggered when the DC counter reaches 0)
   true - enabled (default)
   false - disabled

chit.helpers.semirare: Enables or disables the Semi-Rare helper (triggered when the Fortune Cookie counter reaches 0)
   true - enabled (default)
   false - disabled

chit.helpers.spookyraven: Enables or disables information about Lights Out adventures in Spookyraven Manor
   true - enabled (default)
   false - disabled

chit.helpers.xiblaxian: Enables or disables the Xiblaxian materials counter when you are wearing a Xiblaxian holo-wrist-puter 
   true - enabled (default)
   false - disabled
-------------------------------------------------------------------------------------
chit.effects.classicons: Replaces effect icons with class-specific icons
   Comma-separated list of classes to replace
      none - does nothing (default)
      sc - replace SC buffs with a seal club
      tt - replace TT buff icons with a turtle
      pm - replace PM buff icons with a pasta spoon
      sa - replace SA buff icons with a saucepan
      db - replace DB buff icons with a disco ball
      at - replace AT buff icons with an accordion (useful in conjunction with chit_bumpsongs)
         Example: tt,at - replaces only TT and AT buffs

chit.effects.showicons: Shows effect icons, or doesn't (compact-style)
   true - show them (default)
   false - don't show them
chit.effects.modicons: Allows icons for effects to be modified. This is mostly used to differential timers.
   Default: true
chit.effects.layout: Comma-separated list
   buffs - regular effects
   intrinsics - intrinsic effects
   songs - only if present, this will cause all active AT songs to be displayed separately. (And other limited quantity buffs like Boris and Jarlsberg)
   Example: 
      intrinsics,limited,buffs - displays intrinsic effects first, then any AT songs, then all other effects/buffs
   Default: songs,buffs,intrinsics
chit.effects.usermap: Allows you to use personalized versions of chit_effects.txt
   true:  uses chit_effects_<yourname>.txt
   false: uses chit_effects.txt  (default)
chit.effects.describe: Adds descriptions for each active effect.
   Default: true
-------------------------------------------------------------------------------------
chit.thrall.showname: If true, shows the thrall name instead of type on the thrall brick
   Default: false
-------------------------------------------------------------------------------------
chit.toolbar.moods: Shows or hides toolbar icon from changing and executing moods
   bonus: shows two icons, one for changing and the other for executing
   false: Does not show either
   Default: true -- shows one icon to change and execute moods
-------------------------------------------------------------------------------------
chit.kol.coolimages: Shows or hides KoL's images for Extreme Meter and Zombie Horde
   Default: true
-------------------------------------------------------------------------------------
chit.disable: If this is set true, then chit will be disabled
   Default: false
-------------------------------------------------------------------------------------
chit.checkversion: Automatically check for new versions once a day
   Must be enabled for the "update" brick to work
   Default: false

chit.autoscroll: Remembers the scroll of your walls when the charpane refreshes (true/false)
   Default: true
               
*************************************************************************************
Chez offers many thanks to:
   Zarqon, for his zlib library
   Bale, from whose CounterChecker script I stole some ideas and code
   All the countless KoLMafia devs and contributors, whose work make all our little pet projects possible
   Ereinion and Caprosmaster, for helping with initial testing and feedback
   Icons from http://www.famfamfam.com/lab/icons/silk/
Bale also wants to offer thanks to:
   AlbinoRhino who has helped me with javascript, html and css when it exceeded my ability
   ckb who wrote the tracker brick and added display and parsing for effects descriptions
   soolar who wrote the amazing gear Brick
   Many other people who have inspired and assisted me in with this project in ways that are hard to quantify
*************************************************************************************
