# ManliCompare
Comparing gear stats to your off specs, so you don't have to!

`x` - This gear has no stat that you're tracking, useless for that specs

`[E]` -  This is either equipped by that spec currently or perfectly equal to what is


# Installation
Copy the `ManliCompare-master` folder to the AddOns directory (`~\World of Warcraft\Interface\AddOns`) and

# Alpha Test
This is a pretty early concept, so things to bear in mind:

- I just want test stat comparison right now, so this won't work with dual wielding and will only compare against the first ring and first trinket, these need a special case once I know the maths ain't wrong.

- Only change your spec, don't change your equipment sets manually, I have no idea what will happen but I'm pretty sure it won't be good.


- This will overwrite any equipment sets you have that are named the same as a spec, either rename, back up or be okay with losing your equipment sets.

- There is no user options menu (Yet™) so be sure to let me know the class, specs and stats you'll be using (weights can be found on Noxxic or decide yourself) e.g.
```
Shaman =
{
    Enhancement =
    {
      Agility = 9.08,
      Haste = 7.58,
      Mastery = 6.08,
      CriticalStrike = 4.58,
      Versatility = 3.08
    },
    Restoration =
    {
      Intellect = 9.06,
      Haste = 3.06,
      Mastery = 7.56,
      CriticalStrike = 6.06,
      Versatility = 4.56
    }
}
```
- As above, you will need to create an equipment set for each of the specs you want to compare, if you don't have an equipment set with the same name as a spec it *should* ignore it. Note: these equipment sets will auto update as you change gear. Also, set these equipment sets to auto equip on spec change by right clicking on the set and choosing your spec.

- Due to reasons after creating your equipment set for a spec (name must be exactly the same, case and everything), switch to that spec and equip any new bit of gear, currently the spec/set profiles are generated when your equipped gear changes, you only need to do this the first time you set up the equipment set, I'll get round to fixing this one day

- Because getting stats from WoW items is a bit fucky, you need to switch to each spec you want to track before they will show up in the tooltip. This might not be avoidable, but I'm trying to work round it.

- It's entirely possible that I forgot how to calculate percentages, so let me know if anything seems wrong.

Cheers
