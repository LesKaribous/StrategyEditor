# StrategyEditor

## 🧠 Présentation

**StrategyEditor** est un outil interactif développé avec **Processing** permettant de :
- Créer, visualiser et éditer des stratégies de déplacement pour un robot
- Simuler graphiquement les trajectoires
- Afficher des POIs, overlays, rosaces, et effets visuels
- Gérer une interface multi-fenêtres (carte + GUI)

---

## 📂 Structure du projet

| Fichier              | Rôle principal |
|----------------------|----------------|
| `StrategyEditor.pde` | Fenêtre principale avec la carte, le terrain, les points |
| `GUI.pde`            | Interface graphique ControlP5 (sliders, boutons...) |
| `StrategyPoint.pde`  | Classe représentant un point de stratégie |
| `POI.pde`            | Chargement et affichage des POIs depuis un fichier `.h` |
| `Simulation.pde`     | Simulation du déplacement robot avec easing et visualisation |
| `OverlayLayer.pde`   | Couche d'affichage : zone de départ, axes, rosace, flou |

---

## 🚀 Fonctionnalités principales

- Placement manuel des points de stratégie
- Snapping automatique sur POIs
- Déplacement fluide (simulation avec easing)
- Système de sauvegarde JSON + auto-save
- Overlay avec :
  - Zones colorées
  - Axes X/Y
  - Rosace à 360° avec angles, A/B/C
  - Flou d’arrière-plan
- Robot affiché à l’échelle réelle (mm → px)

---

## 🕹️ Commandes & UI

- **S** : démarrer la simulation
- **GUI** :
  - Boutons "Next"/"Prev point"
  - Reset, Load, Save
  - Affichage de l’overlay, rosace, taille robot...

---

## 🗃️ Fichier de POIs

POIs chargés depuis un fichier C-style `.h` du type :

```c
const Vec2 y2 = Vec2(2775,1775);  //BLUE
```

Le nom (`y2`) et les coordonnées (`x, y`) sont extraits pour l’affichage et le snapping.

---

## 📐 Calibration robot

Le robot est dessiné à l’échelle :
- `robotWidth_mm`, `robotHeight_mm`, `robotHitbox_mm` dans `Simulation.pde`
- Taille ajustable, cercle de collision visible
- L’image ne tourne pas (robot holonome)

---

## 🔧 Extensions possibles

- Ajout d’un `angle` ou `action` sur les StrategyPoints
- Visualisation multi-robots
- Génération automatique de trajectoires (splines, courbes, etc.)
- Export vers format code (ex: C++ / ROS)

---

## 📄 À faire

- Ajouter gestion de `angle` sur les points
- Export CSV ou format compilable
- Masquage dynamique des layers (rosace, POIs...)
- Zoom, drag map (panning)

---

## 👨‍💻 Auteur

Développé par [toi !] dans le cadre d’un projet robotique (Eurobot, etc.)

---

## 🧠 Remarques

Ce projet est parfaitement adapté pour :
- Du prototypage stratégique rapide
- De la visualisation en match
- De la documentation pour équipe ou jury

