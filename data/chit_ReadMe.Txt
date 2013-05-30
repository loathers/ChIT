CHaracter Info Toolbox
A character pane relay override script
By Chez up to v 0.6.0
All revisions after that by Bale

*************************************************************************************
Chez offers many thanks to:
   Zarqon, for his zlib library
   Bale, from whose CounterChecker script I stole some ideas and code
   All the countless KoLMafia devs and contributors, whose work make all our little pet projects possible
   Ereinion and Caprosmaster, for helping with initial testing and feedback
   Icons from http://www.famfamfam.com/lab/icons/silk/
*************************************************************************************
Bale also wants to offer thanks to:
   AlbinoRhino who has helped me with javascript, html and css when it exceeded my ability
*************************************************************************************

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
   trail:      Recent adventures
   quests:     Quest nudges (when available)
   helpers:    Adventure helpers (described in more detail below)
   effects:    List of current effects (Not available in toolbar)
   organs:     similar to stats, but only shows spleen, stomach and liver (more useful when used in the toolbar)
   substats:   similar to stats, but only shows muscle,myst and moxie (more useful when used in the toolbar)
   modifiers:  Some useful modifiers (+meat, +items, +combat, ML, DA, DR etc)
   elements:   Shows the KoL elements chart from the wiki (also mostly for the toolbar)
   update:     Notifies you when new versions of CHIT are available
         
So how do you design and build your own house? Easy. Simply place your bricks in the area you want, in the order you want them.
All of the preferences below can be found in /data/vars_yourname.txt
-------------------------------------------------------------------------------------
chit.roof.layout: Comma-separated list of bricks to place in your roof
          Default: character,stats,familiar,trail

chit.walls.layout: Comma-separated list of bricks to place in your walls
          Default: helpers,effects

chit.floor.layout: Comma-separated list of bricks to place in your floor
          Default: update
                  
chit.toolbar.layout: Comma-separated list of bricks to place in the toolbar
          Default: quests,modifiers

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
          Default: muscle,myst,moxie|stomach,liver,spleen|hp,mp,axel|mcd
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
-------------------------------------------------------------------------------------
chit.effects.classicons: Replaces effect icons with class-specific icons
          Comma-separated list of classes to replace
          Valid values: 
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
          songs - only if present, this will cause all active AT songs to be displayed separately (Also Boris and Jarlsberg buffs)
           Example: 
             intrinsics,songs,buffs - displays intrinsic effects first, then any AT songs, then all other effects/buffs
          Default: 
             buffs,intrinsics (standard behaviour)
chit.effects.usermap: Allows you to use personalized versions of chit_effects.txt
          true:  uses chit_effects_<yourname>.txt
          false: uses chit_effects.txt  (default)
-------------------------------------------------------------------------------------
chit.toolbar.moods: Shows or hides toolbar icon from changing and executing moods
          both: shows two icons, one for changing and the other for executing
          Default: true
-------------------------------------------------------------------------------------
chit.kol.coolimages: Shows or hides KoL's images for Extreme Meter and Zombie Horde
          Default: true
-------------------------------------------------------------------------------------
chit.disable: If this is set true, then chit will be disabled
          Default: false
-------------------------------------------------------------------------------------
chit.checkversion: Automatically check for new versions once a day
          Must be enabled for the "update" brick to work
          Default: true
