# Data Dump for Farming Simulator

The main purpose of this mod is to save the global tables, functions, classes and variables from Farming Simulator to files. Use these files to better understand the Farming Simulator object model through reverse engineering.

With these global objects as a starting point, you can then use the console command 'dtSaveTable' from the mod 'PowerTools: Developer' to write whole Lua tables (and full table hierarchies) to file for further analysis.

E.g. if the output of Data Dump contains a global table called 'g_gui' you can then execute the console command 'dtSaveTable g_gui g_gui.lua 10' to save the g_gui table to a file called g_gui.lua with a max dept of 10 levels.

## USAGE
1. Open the developer console in FS. 
2. Type 'ddDump' and hit [ENTER]
3. Review the files in the '..\Documents\My Games\FarmingSimulator2022\modSettings\FS22_000_DataDump' folder
