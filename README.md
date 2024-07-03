# 3D Procedural Landmass Generator in Godot
## Overview

Created a 3D procedural landmass generator in godot 3.5.4 for the advanced games engineering module. Designed to be heavily customisable with many variables that change the overall look of it.

## Features

- **Noise-Based Mesh Generation**: Uses OpenSimplexNoise to generate the terrain mesh. Ability to modify seed, octaves, period, etc. Custom height-based terrain shader used to texture the land with grass, snow and sand.
- **Water Shader**: Custom water shader written for this project. Includes foam around the waters edge, shallow depth transparancy, fresnel effect and moving waves.
- **Clouds**: Utilises the CPUParticles node to generate low cost billboarding clouds that move around the sky.
- **Day Night Cycle**: Uses deltatime to vary a sky environments direction and colour to simulate a day night cycle.

## Screenshots
![dawnclouds](https://github.com/MatthewLenathen/adv-games-eng/assets/71607754/46bf05ad-7b49-4ebd-957e-2e377df50dee)
![transparancy](https://github.com/MatthewLenathen/adv-games-eng/assets/71607754/f1457ef1-3252-4bae-bb07-53235acf8892)
![terrain](https://github.com/MatthewLenathen/adv-games-eng/assets/71607754/178a78b1-08cf-4ccf-b52f-a046d9186fa9)
![dusk](https://github.com/MatthewLenathen/adv-games-eng/assets/71607754/ababb5ae-491e-41b5-b35c-6782e9b6e88e)
![foam](https://github.com/MatthewLenathen/adv-games-eng/assets/71607754/1fa17278-5902-43a8-83ee-57b7672f9368)
