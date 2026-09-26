# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Game Is

A Godot 4.7 mini-game collection designed for toddlers (ages 1–4). The focus is on simple tap/drag interactions, bright visuals, and immediate audio feedback — no reading required. Each mini-game lives in its own scene under `scenes/`.

### Mini-Games

**Shadow Matching** (`scenes/shadow-matching/`)
Toddlers drag colorful 2D shapes (smiling squares, balls, stars, etc.) onto their matching dark silhouettes. Success is rewarded with a sound and animation. The shape assets were AI-generated to be cute and friendly.

**Cars** (planned, assets at `assets/cars/`)
A vehicle-recognition or sorting game using five vehicle types: regular car, F1 racer, fire truck, police car, and taxi. The exact mechanic is TBD but likely involves matching, identifying, or driving the cars.

### Audio Design
All sound feedback is centralized in `assets/audio/`:
- `correct.mp3` / `wrong.mp3` — immediate right/wrong response
- `success.mp3` — level/game completion
- `bobble-pop.wav` — tap/touch interaction
- `pull.wav` — drag interaction

## Engine & Project Setup

- **Godot 4.7**, Forward Plus renderer, D3D12 on Windows
- **Jolt Physics** for 3D (though the games appear 2D)
- Window stretch mode: `canvas_items` + `expand` — UI scales to any screen size, important for tablet/phone play
- To run: open `project.godot` in Godot 4.7+ and press F5

## Design Principles

- All interactions must work with a single tap or a simple drag — no complex gestures
- Every correct action plays audio feedback immediately
- Scenes are self-contained; each mini-game should function independently
- Visual targets should be large enough for toddler fingers (touch targets ≥ 100px at 1080p)
