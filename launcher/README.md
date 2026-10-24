# Launcher

`AscensionLauncher.exe` sets up the game (video, controls, language, mods, saves) and starts it: open it, or run `scripts\windows\launcher.ps1` (`-Play` starts the game with the saved settings and no window). It finds this repository by walking up from this folder, so it stays here.

What it needs beside it is `Cinzel-Black.ttf` (the Cinzel typeface, SIL Open Font License, `OFL-Cinzel.txt`), which the game's own overlay also reads. The artwork and music are inside the `.exe`; files of the same names (`background*.jpg/png`, `logo.png`, `icon-2.png`, `music.mp3`) in `launcher\assets\` take their place.

Settings are kept in `%APPDATA%\ascension-launcher\settings.json`.

The source is not in this repository: it lives in the work repository (`work/launcher`), whose `build.ps1` makes this `.exe` and puts it here.
