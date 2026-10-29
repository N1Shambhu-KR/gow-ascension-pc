# Launcher

The launcher is no longer kept here: install it from the releases (`AscensionLauncher_<version>_x64-setup.exe`), choose
this folder under Advanced > Game folder the first time, and it updates itself. Its source is the private
`work/launcher-tauri`.

What stays here is `Cinzel-Black.ttf` (the Cinzel typeface, SIL Open Font License, `OFL-Cinzel.txt`), which the game's
overlay reads (the launcher passes it as `PS3_OVERLAY_FONT`). Files named `background*.jpg/png`, `logo.png`,
`icon-2.png` and `music.mp3` in `launcher\assets\` replace the launcher's art.

Settings are kept in `%APPDATA%\ascension-launcher\settings.json`.
