# AD(d)A 2️⃣0️⃣4️⃣8️⃣

ADdA_2048 is a terminal-based implementation of the classic 2048 sliding-tile puzzle game, written in Ada and designed with formal verification in mind using SPARK/GNATprove.

# 🚀 Build And Run

## 🛠️ Toolchain Used
- Alire: `2.0.2`
- Selected Alire toolchain:
  - `gnat_native 14.2.1` (default)
  - `gprbuild 22.0.1` (default)
- Dependency crate:
  - `gnatprove 14.1.1` (from `alire.toml`)

### 🔎 Check your local setup:
```
alr toolchain
alr --version
```

## 🔨 Build and run the project using Alire

```
alr build
alr run
```

## ✅ Proof (GNATprove)
Project proof defaults are in `adda_2048.gpr`:
- `--mode=prove`
- `--level=2`
- `--prover=all`
- `--timeout=60`

▶️ Run:
```sh
alr exec -- gnatprove -P adda_2048.gpr
```

📄 Proof output:
```text
obj/development/gnatprove/gnatprove.out
```


## 🐳 Build and run using Docker
Build:
```sh
docker build -t adda_2048 .
```

Run:
```sh
docker run --rm -it adda_2048
```

Run proof in container:
```sh
docker run --rm -it adda_2048 alr exec -- gnatprove -P adda_2048.gpr
```



# 📜 Rules of 2048

  - The game is played on a square board (default size is 4x4).
  - At the start of the game, 2 tiles spawn that each hold either a 2 or a 4.
  - Combine equal tiles by moving in one direction; merged tiles add to score.
  - After each valid move, a new tile (2 or 4) appears.
  - The probability of spawning a 2 is 90% (a 4 spawns with a probability of 10%).
  - You win when a tile reaches 2048 (you may continue for a higher score).
  - The game ends when no moves are possible.

## 🎮 Controls
- `W/A/S/D`: move
- `U`: undo
- `Y`: redo
- `R`: restart
- `C`: continue after hitting 2048
- `Q`: quit

### 📝 Input notes:
- Only the first character from each input line is used.
- Extra characters are ignored with a warning.

# 🧭 Repository Layout
- `src/main.adb`: entry point
- `src/logic/`: game logic, history, random tiles, high score, command handling
- `src/tui/`: terminal menu, input, display
- `src/types/`: core game types and invariants
- `src/verification/`: ghost helpers used by contracts/proofs
- `config/`: Alire-generated project configuration

## 🧩 Notes
- Some units are intentionally `SPARK_Mode => Off` (I/O, randomness, file persistence paths).
- In Docker, `.highscore` is ephemeral unless mounted from host storage.


# ✨ Special implementation features
- Variable board sizes (`4x4` to `8x8`) selected at startup.
- Undo/redo history (`U`/`Y`) with bounded stack.
- High-score tracking per board size, persisted to `.highscore`.
- SPARK-oriented contracts in game/types/history code.
- Ghost helpers for proof in `src/verification/verification-game_ghost.*` and `src/logic/logic-history.ads`.



# 🧩 Known Limitations

  - SPARK proof excludes I/O and randomness-related units (marked `SPARK_Mode => Off`).
  - In Docker, high scores are not persisted across sessions by default (use a bind mount to keep `.highscore`).
