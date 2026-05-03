#!/usr/bin/env bash
# ============================================================
# Tower of Hanoi — Bash Script
# LFX Mentorship Coding Challenge: RISC-V High Precision Code Base
# Author: Zainab Ashraf
# ============================================================
# This script solves the Tower of Hanoi puzzle with simple
# ASCII graphics. It demonstrates:
#   - RECURSION: the hanoi() function calls itself to break
#     the problem into smaller sub-problems.
#   - ITERATION: the draw_towers() function loops over each
#     peg and each row to render the ASCII display.
# ============================================================

# --- Configuration ---
DISKS=4          # Number of disks (change this to try other sizes)
DELAY=0.5        # Pause between moves in seconds

# --- State ---
# Three pegs stored as space-separated strings of disk numbers.
# Larger number = wider disk. Disk 1 is the smallest.
declare -a PEG
PEG[1]=""
PEG[2]=""
PEG[3]=""

MOVE_COUNT=0

# --- Initialise pegs ---
# ITERATION: this loop fills peg 1 with all disks (largest first)
init_pegs() {
    PEG[1]=""
    for (( d=DISKS; d>=1; d-- )); do
        PEG[1]="${PEG[1]} $d"
    done
    PEG[1]="${PEG[1]# }"   # trim leading space
    PEG[2]=""
    PEG[3]=""
}

# --- Push / Pop helpers ---
push_disk() {
    local peg=$1 disk=$2
    if [[ -z "${PEG[$peg]}" ]]; then
        PEG[$peg]="$disk"
    else
        PEG[$peg]="${PEG[$peg]} $disk"
    fi
}

pop_disk() {
    local peg=$1
    local top
    top=$(echo "${PEG[$peg]}" | awk '{print $NF}')
    PEG[$peg]=$(echo "${PEG[$peg]}" | sed 's/ *[^ ]*$//' | sed 's/ *$//')
    echo "$top"
}

# --- ASCII Graphics ---
# ITERATION: nested loops draw each peg row by row.
draw_towers() {
    local width=$(( DISKS * 2 + 3 ))  # max display width per peg
    clear

    printf "\n  Tower of Hanoi  —  %d disks  —  Move %d\n\n" "$DISKS" "$MOVE_COUNT"

    # Build arrays of disks per peg (bottom to top)
    local -a col1 col2 col3
    IFS=' ' read -ra col1 <<< "${PEG[1]}"
    IFS=' ' read -ra col2 <<< "${PEG[2]}"
    IFS=' ' read -ra col3 <<< "${PEG[3]}"

    # ITERATION: draw from top row to bottom row
    for (( row=DISKS; row>=1; row-- )); do
        local line="  "
        for peg in 1 2 3; do
            local -n col="col${peg}"
            local disk="${col[$((row-1))]}"
            local half=$(( width / 2 ))

            if [[ -n "$disk" ]]; then
                local pad=$(( half - disk ))
                local bar=$(( disk * 2 - 1 ))
                printf -v seg "%*s%s%*s" "$pad" "" "$(printf '%0.s=' $(seq 1 $bar))" "$pad" ""
            else
                printf -v seg "%*s|%*s" "$half" "" "$half" ""
            fi
            line+="$seg  "
        done
        echo "$line"
    done

    # Base line
    local base_seg
    printf -v base_seg "%s" "$(printf '%0.s-' $(seq 1 $width))"
    echo "  ${base_seg}  ${base_seg}  ${base_seg}"
    echo "  $(printf '%*s' "$((width/2))" "")A$(printf '%*s' "$((width/2))" "")  $(printf '%*s' "$((width/2))" "")B$(printf '%*s' "$((width/2))" "")  $(printf '%*s' "$((width/2))" "")C$(printf '%*s' "$((width/2))" "")"
    echo ""
}

# --- RECURSION: the core algorithm ---
# hanoi(n, from, to, via) moves n disks from peg 'from' to peg 'to'
# using peg 'via' as temporary storage.
#
# Base case:  n == 1 → move the single disk directly.
# Recursive step:
#   1. Move top (n-1) disks from 'from' to 'via'  [recursive call]
#   2. Move the largest disk from 'from' to 'to'   [base action]
#   3. Move top (n-1) disks from 'via' to 'to'     [recursive call]
#
# Each recursive call reduces n by 1, guaranteeing termination.
hanoi() {
    local n=$1 from=$2 to=$3 via=$4

    if (( n == 1 )); then
        # BASE CASE — move one disk directly
        local disk
        disk=$(pop_disk "$from")
        push_disk "$to" "$disk"
        (( MOVE_COUNT++ ))
        draw_towers
        sleep "$DELAY"
        return
    fi

    # RECURSIVE CALL 1 — clear the top (n-1) disks out of the way
    hanoi $(( n - 1 )) "$from" "$via" "$to"

    # Move the largest remaining disk
    local disk
    disk=$(pop_disk "$from")
    push_disk "$to" "$disk"
    (( MOVE_COUNT++ ))
    draw_towers
    sleep "$DELAY"

    # RECURSIVE CALL 2 — stack the (n-1) disks onto the destination
    hanoi $(( n - 1 )) "$via" "$to" "$from"
}

# --- Entry point ---
main() {
    init_pegs
    draw_towers
    sleep 1

    # Solve: move all DISKS from peg 1 → peg 3, using peg 2
    hanoi "$DISKS" 1 3 2

    printf "\n  Solved in %d moves (minimum possible: %d)\n\n" \
        "$MOVE_COUNT" "$(( (1 << DISKS) - 1 ))"
}

main
