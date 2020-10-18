# XLua-scripts-for-X-Plane

Various XLua scripts for use in [X-Plane](https://www.x-plane.com/).


&nbsp;

## Requirements

- Any X-Plane version with [XLua](https://github.com/X-Plane/XLua) support
- [XLua](https://github.com/X-Plane/XLua)

&nbsp;

## Notes about the scripts

Documentation about each script can be found in the respective folder.

Some ground rules regarding XLua scripts:

- Scripts can be reloaded with the _"Developer"_ --> _"Reload the Current Aircraft"_ menu option in X-Plane
- There is no developer console output by default. If you need debug output, start X-Plane from the console or a terminal and read it there
- For developer console output, you will need to compile and use [this XLua fork](https://github.com/aeroc7/XLua) instead of the default one and replace the "print" statements in the scripts with "log"
- The only place to actively get XLua support and scripting help is [in the thread on the X-Plane.org forums](https://forums.x-plane.org/index.php?/forums/topic/154351-xlua-scripting/)
- A primer for XLua programming can be found in [this post](https://forums.x-plane.org/index.php?/forums/topic/154351-xlua-scripting/&tab=comments#comment-1460039) by Jim Gregory.

&nbsp;

## Installation

1. Check if the XLua folder is present in aircraft's _"plugins"_ folder.   
If yes, skip step 2 and proceed with step 3.   
If no, proceed with step 2.

2. Copy Xlua plugin folder from any default aircraft (e.g. *Aircraft/Laminar Research/Cessna 172SP/plugins/xlua/*) into the target airplane's _"plugins"_ folder, then delete all subfolders in the _"Scripts"_ folder of the copied _"xlua"_ folder

3. Download the scripts from this repository ([_"Code"_ --> _"Download as ZIP"_](https://github.com/JT8D-17/XLua-scripts-for-X-Plane/archive/main.zip)) and extract the archive.

4. Copy the folder into the _"[Aircraft folder]/plugins/xlua"_ folder of the aircraft.

5. Run X-Plane. Activate debug output (see note above and each script's readme on what to edit)

&nbsp;

## Uninstallation

1. Delete the script's folder from  _"[Aircraft folder]/plugins/xlua"_


&nbsp;

## License

All scripts are licensed under the European Union Public License v1.2 (see EUPL-1.2-license.txt). Compatible licenses (e.g. GPLv3) are listed in the section "Appendix" in the license file.


