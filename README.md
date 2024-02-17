# hsc-open-script-api
Open API for developing missions with halo

# The README
The point of the license is to say: use for whatever, just don't take the code and sell as a standalone. I put a straight month 40hr work week on this WHILE working my regular job.

These scripts are standalone and don't require any other scripts from the halo globals folder.

These scripts should shorten your development time per mission to under 2-3 hours instead of a whole weekend.

These scripts also expand the replayability of your missions.

Much love you guys, it would bring joy to my heart to see you excel at modding the game with the heavy load out of the way now.


# How to use:
Just download the repository and stick the files in the globals folder of your halo reach data folder.
For some reason I had trouble getting scenarios to recognize scripts outside the globals/scenario folders.

The scripts list the required files at the top. No surprises.
The scripts also list the required sapien editor objects that need to be placed before they can compile. I tried to avoid requiring it as much as possible. Scripts that don't require it to compile will refuse to run though.


Its amazing what could have been if the developers focused more on the firefight game mode. And thanks to 343 expanding it to 8 players, the possibilities are near limitless.

# Youtube tutorials
## [Halo Reach Firefight Tutorial - Start to Finish](https://www.youtube.com/ "Halo Reach Firefight Tutorial - Start to Finish")
## [Halo Reach - HSC Open Script API Showcase](https://www.youtube.com/ "Halo Reach - HSC Open Script API Showcase")

# Available Game Modes:
## Warzone (vs firefight)
> same principle but more support for expanding hazards and reinforcements for both teams. It tries to make PvP actually fun.

**osa_firefight_warzone.hsc**
## Extraction
> Rescue civilains trying to escape the area, the team with most killed/saved wins the round. The mission will warn players when one team is near victory.

**osa_extraction.hsc**

# Upcoming Game Modes:
## VIP Protection
> Spartans/Elites must escort squads to their destination, don't lose too many soldiers. Some squads are coming in, others are leaving.

## King of the Hill
> same as multiplayer mode, AI will attempt to hold certain regions to score points.

## Base Defense
> Each team gets a generator to defend from the other team. Splits map in half.

## Invasion
> Functions the same as multiplayer invasion, but only specific AI can trigger the next phase of the mission. Players do not.
