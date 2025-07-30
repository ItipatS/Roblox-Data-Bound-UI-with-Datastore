#  Roblox Modular UI Framework

This project is a **modular and scalable UI system** for Roblox games. Designed with clean architecture and performance in mind, it organizes UI control, transitions, and state management into distinct modules for maintainability and reusability.

---

##  Features

###  Modular UI System
- Dynamically opens/closes UI panels using tween transitions
- Tracks currently opened UIs and composite group states
- Supports nested menus and prevents UI conflict with in-transition tracking

### 🔧 Tween & Effect Managers
- `TweenManager`: Handles all UI transitions cleanly through TweenService
- `TierEffectManager`: Adds tier-based visual effects to items or UI elements

### 📦 Inventory & Quick Menu
- `InventoryManager`: Manages player inventory data and UI sync
- `QuickMenu`: Pop-up shortcut menu with UI integration
- `TooltipBuilder`: Dynamically generates item/tooltips on hover

### 🧼 Memory Management
- Built-in cleanup system to manage UI lifecycles and avoid memory leaks

---

##  How It Works

### UIManager
At the core of the system is `UIManager`, which:
- Caches references to GUI elements within `PlayerGui.Interface`
- Handles UI state (opened/closed) using custom flags
- Supports callback functions for inventory state tracking
- Allows composite UIs to open/close as a group
- Stores original parents of UI elements to restore them correctly

### TweenManager
A dedicated module that centralizes tween creation:
- Animates opening/closing transitions (scale, position, transparency)
- Prevents duplicate tweens by cancelling overlapping transitions

### InventoryManager & TooltipBuilder
- `InventoryManager` listens for inventory changes and updates UI
- `TooltipBuilder` dynamically renders detailed item/tooltips
  based on metadata like rarity, tier, or stats

---

## Folder Structure

```
src/
├── client/
│   ├── Control/         # Input handling
│   ├── Data/            # Local state/data stores
│   ├── UI/              # UI control logic (this project)
│   ├── Utility/         # Helpers (e.g., tween, cleanup)
├── server/
│   ├── Databases/       # Player data logic (e.g., ProfileService)
├── shared/
│   ├── Maid.luau        # Cleanup utility
```

---

##  Ideal Use Cases

- RPG inventory systems
- In-game shop/tooltips
- Sandbox/tycoon UI interfaces
- Skill trees, upgrade menus, radial UIs

## Demo Video
<a href="https://www.youtube.com/watch?v=0NLv2Lb7Fcc" target="_blank" rel="noopener noreferrer">
  <img src="https://img.youtube.com/vi/0NLv2Lb7Fcc/0.jpg" alt="Watch the video">
</a>

---

##  Tech Stack

- Roblox Luau
- Rojo / Aftman project structure
- ProfileService (for persistent storage)

---

## Notes

> The included `PlacementService` was accidentally committed and is **not used** in this UI system. You can safely ignore or remove it.

---

##  Author
Built and maintained by Itipat Songsampansakul as part of a portfolio project.
