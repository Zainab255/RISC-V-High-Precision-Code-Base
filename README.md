# Tower of Hanoi — LFX Mentorship Coding Challenge

**Broadening the RISC-V High Precision Code Base and Reach**
Submitted by: Zainab Ashraf — ashraf.zainab.r@gmail.com

---

## What this is

A Tower of Hanoi solver written as a pure bash script with ASCII animation. It runs on any Linux or macOS terminal with no dependencies — including RISC-V Linux distributions — making it a clean portability demonstration for the challenge.

```
  Tower of Hanoi  —  4 disks  —  Move 7

      =           =            |
     ===          =            |
    =====         |           =
   =======        |           =
  -----------  -----------  -----------
       A            B            C
```

---

## How to run

```bash
# Clone the repo
git clone https://github.com/Zainab255/tower-of-hanoi-riscv.git
cd tower-of-hanoi-riscv

# Make the script executable
chmod +x tower_of_hanoi.sh

# Run it
./tower_of_hanoi.sh
```

Works on any system with bash 4.0 or later — including RISC-V boards running Ubuntu, Debian, or Fedora.

---

## Customise it

Open `tower_of_hanoi.sh` and edit the top two lines:

```bash
DISKS=4       # Try 3, 5, or 6
DELAY=0.5     # Seconds between moves (use 0.1 for faster)
```

---

## How the algorithm works

The puzzle has three pegs (A, B, C) and a stack of disks on peg A, largest at the bottom. The goal is to move all disks to peg C, one at a time, never placing a larger disk on top of a smaller one.

### Recursion

The `hanoi()` function solves this by calling itself:

```bash
hanoi() {
    local n=$1 from=$2 to=$3 via=$4

    # Base case: one disk, move it directly — stops the recursion
    if (( n == 1 )); then
        move_disk "$from" "$to"
        return
    fi

    # Recursive call 1: move top (n-1) disks out of the way
    hanoi $(( n - 1 )) "$from" "$via" "$to"

    # Move the largest disk to the destination
    move_disk "$from" "$to"

    # Recursive call 2: move (n-1) disks from spare peg to destination
    hanoi $(( n - 1 )) "$via" "$to" "$from"
}
```

Each call reduces `n` by 1, so the recursion always terminates at `n == 1`. A 4-disk puzzle makes 15 calls total (2^4 - 1). You never write the individual moves — the recursion generates them automatically.

### Iteration

Two `for` loops handle the non-recursive parts of the script:

**Setup** — fills peg A with all disks, largest first:

```bash
# ITERATION: load disks onto peg A from bottom to top
for (( d=DISKS; d>=1; d-- )); do
    PEG[1]="${PEG[1]} $d"
done
```

**Rendering** — draws every peg, every row, each frame:

```bash
# ITERATION: loop over rows top to bottom, pegs left to right
for (( row=DISKS; row>=1; row-- )); do
    for peg in 1 2 3; do
        draw_cell "$row" "$peg"
    done
done
```

---

## Why this is relevant to RISC-V

Bash ships as a standard shell on every major RISC-V Linux distribution. This script:

- Has zero external dependencies beyond bash itself
- Uses only POSIX-compatible tools (`awk`, `sed`, `printf`) that are available on minimal RISC-V installs
- Demonstrates that even animated terminal programs run correctly on RISC-V without any architecture-specific changes
- Serves as a simple, readable test case for verifying bash and core utility correctness on a new RISC-V build or toolchain

The minimum move count for n disks is always 2^n - 1. The script verifies this at the end, giving a quick sanity check that arithmetic works correctly on the target platform.

---

## Complexity

| Disks | Moves | Approximate time (0.5s delay) |
|-------|-------|-------------------------------|
| 3     | 7     | ~4 seconds                    |
| 4     | 15    | ~8 seconds                    |
| 5     | 31    | ~16 seconds                   |
| 6     | 63    | ~32 seconds                   |

Time complexity: O(2^n). Space complexity: O(n) for the recursion stack.

---

## Author

**Zainab Ashraf**
GitHub: [github.com/Zainab255](https://github.com/Zainab255)
LinkedIn: [linkedin.com/in/zainab-4a5b0a265](https://linkedin.com/in/zainab-4a5b0a265)

LFX Mentorship Application — 2026
