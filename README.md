# ⚡ AlgoFlow: DSA Algorithm Visualizer

A beautiful, high-performance cross-platform Flutter application designed to make learning Data Structures and Algorithms (DSA) interactive, visual, and engaging.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue)

<img width="1024" height="487" alt="ChatGPT Image Apr 5, 2026, 04_43_38 AM" src="https://github.com/user-attachments/assets/90ba452a-b1e3-4e8e-9aaa-a8fa9986aa5a" />


## 🌟 Key Features

*   **Interactive Visualizations:** Step-by-step frame-based breakdown of complex algorithms to help you understand the core execution logic iteratively.
*   **Extensive Algorithm Library:**
    *   📊 **Sorting:** Merge Sort, Insertion Sort, etc.
    *   🕸️ **Graphs:** A* Pathfinding, BFS, DFS.
    *   🌲 **Trees:** BST Search, Traversals.
    *   🧩 **Dynamic Programming:** Fibonacci, Coin Change.
    *   🔙 **Backtracking:** N-Queens, Maze algorithms.
*   **Detailed Analytics Cards:** Rich structural metadata for each algorithm, dynamically displaying taglines, calculated time complexity, categorized disciplines, and difficulty.
*   **Personalized Learning Flow:**
    *   **Daily Algorithm:** Discover a curated featured algorithm every day.
    *   **Continue Learning:** Easily pick up visualizers exactly where you left off.
    *   **Bookmarks:** Save your favorite or challenging algorithms to your personal collection.
*   **Premium UI/UX:**
    *   Immersive Dark Theme mode (`#0F0A18`) highlighted by vibrant, distinct category color mapping.
    *   Context-aware dynamic time-based greetings.
    *   Polished Native Splash Screen scaling (Fully optimized for Android 12+ Splash APIs).

## 🛠️ Technology Stack

*   **Framework:** Flutter (Dart `^3.8.1`)
*   **State Management:** [Riverpod (`flutter_riverpod: ^2.5.1`)](https://riverpod.dev/) handles visualizer frame iterations, playback states, and UI reactivity effortlessly outside the widget tree.
*   **Local Storage:** `shared_preferences` securely persists session metrics, progress limits, and user bookmarks locally.

## 🏗️ Architecture

The app is built upon a scalable, decoupled Feature/Layer-based architecture:
*   `lib/algos/`: The execution engine holding the pure generic math, pathing, and recursion scripts that emit visualization frame sequences.
*   `lib/controllers/`: Links the heavy UI and computational logic through `StateNotifier` and `Notifier` bindings managing specific app behaviors.
*   `lib/states/`: Read-only, immutable state representations allowing deterministic rendering.
*   `lib/data/`: Central local registry mimicking a backend database storing categorical tags and algorithm properties.
*   `lib/screens/` & `lib/widgets/`: Highly modular, mobile-responsive layout components ensuring strict prevention of pixel-overflows.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.3.0` or higher
- Dart SDK `^3.8.1` or higher
- Target Device / Emulator (Android, iOS, Web, Desktop)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/maazanwar-dotcom/AlgoFlow-DSA-Algorithm-Visualizer-Flutter-.git
   
## UI Screenshots

<img width="254" height="520" alt="image" src="https://github.com/user-attachments/assets/7e8c7b00-37ea-4548-9706-f7873c7601df" /> <img width="279" height="575" alt="image" src="https://github.com/user-attachments/assets/df356248-2d60-4ae0-ae6b-8c2b05f17ee7" /> <img width="285" height="561" alt="image" src="https://github.com/user-attachments/assets/1818389e-af29-49d5-8ac4-b20a41eaf2ca" /> <img width="286" height="603" alt="image" src="https://github.com/user-attachments/assets/ce9c20b1-4463-47f5-b6a8-386512bd6a35" /> <img width="286" height="640" alt="image" src="https://github.com/user-attachments/assets/1bcbb460-adb9-4e0f-bd36-00977465e14e" /> <img width="286" height="602" alt="image" src="https://github.com/user-attachments/assets/888459b3-40e0-4398-a71d-c3a7e925e6e2" /> <img width="286" height="607" alt="image" src="https://github.com/user-attachments/assets/ea3d2517-bedf-4199-83d9-a045fd471b1c" />









