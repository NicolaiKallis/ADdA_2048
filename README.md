# 🎮 ADDA 2048 (Ada/SPARK)

Terminal-based 2048 implementation in Ada with formal verification using GNATprove.

# ✅ Requirements

- GNAT (Ada compiler)
- Alire (`alr`)
- GNATprove (SPARK toolset)

# 🚀 Quick Start

Build:

```sh
alr build
```

Run:

```sh
alr run
```

# 🐳 Docker

Build the image:

```sh
docker build -t adda_2048 .
```

To pin a different Alire release:

```sh
docker build -t adda_2048 --build-arg ALIRE_VERSION=2.1.0 .
```

Run the game:

```sh
docker run --rm -it adda_2048
```

Run GNATprove:

```sh
docker run --rm -it adda_2048 alr exec -- gnatprove -P adda_2048.gpr --mode=prove --level=1
```

## 🎮 Controls:
- `W/A/S/D` = move
- `U` = undo
- `Y` = redo
- `R` = restart
- `C` = continue after victory
- `Q` = quit

Note: if you enter more than one character on a line, only the first is used.

## 📜 Rules of 2048 (Brief)

- Combine equal tiles by moving in one direction; merged tiles add to score.
- After each valid move, a new tile (2 or 4) appears.
- You win when a tile reaches 2048 (you may continue for a higher score).
- The game ends when no moves are possible.

## ✅ SPARK Verification (GNATprove)

Run GNATprove via Alire:

```sh
alr exec -- gnatprove -P adda_2048.gpr --mode=prove --level=1
```

The proof summary is written to:

```
obj/development/gnatprove/gnatprove.out
```

To check success, look for `Unproved` being empty/zero in the summary table.

### 🧪 Proof scope:
- Proven units: `logic-game`, `logic-history`, `types-game_types` (and supporting ghost functions)
- Excluded from SPARK: I/O and randomness (`tui-*`, `logic-random`, `logic-highscore`, `main`)

### 👻 Ghost methods:
- Defined in `src/logic/logic-game.ads` and implemented in `src/logic/logic-game.adb`.
- Used only for proof (e.g., slice sums, compaction checks) to support GNATprove without affecting runtime behavior.


# 🧭 Project Layout

- `src/main.adb` — program entry point
- `src/logic/` — game logic, history, random tiles, user commands
- `src/types/` — core types and invariants
- `src/tui/` — terminal UI (display + input)

## 🏆 High Score Storage

High scores are saved to a `.highscore` file located at the project root.


# 🧩 Known Limitations

- SPARK proof excludes I/O and randomness-related units (marked `SPARK_Mode => Off`)
- In Docker, high scores are not persisted across sessions by default (use a bind mount to keep `.highscore`)
