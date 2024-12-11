#!/usr/bin/env bash

input_path="${1:-input/11}"

read -ra input < "$input_path"

STONES=0

declare -A cache

halfbase() {
    B=0
    if (( x < 10 )); then
        B=0
    elif (( x < 100 )); then
        B=10
    elif (( x < 1000 )); then
        B=0
    elif (( x < 10000 )); then
        B=100
    elif (( x < 100000 )); then
        B=0
    elif (( x < 1000000 )); then
        B=1000
    elif (( x < 10000000 )); then
        B=0
    elif (( x < 100000000 )); then
        B=10000
    elif (( x < 1000000000 )); then
        B=0
    elif (( x < 10000000000 )); then
        B=100000
    elif (( x < 100000000000 )); then
        B=0
    elif (( x < 1000000000000 )); then
        B=1000000
    fi
}

stones() {
    local x=$1
    local blink=$2

    local key="$x|$blink"
    STONES="${cache[$key]}"
    if [[ -z "$STONES" ]]; then
        halfbase "$x"
        local b=$B

        if (( blink == 0 )); then
            STONES=1
        elif (( x == 0 )); then
            stones 1 $(( blink - 1 ))
        elif (( B != 0 )); then
            stones $(( x / b )) $(( blink - 1 ))
            local X=$STONES
            stones $(( x % b )) $(( blink - 1 ))
            STONES=$(( STONES + X ))
            cache["$x|$blink"]=$STONES
        else
            stones $(( x * 2024 )) $(( blink - 1 ))
        fi
    fi
}

part1=0
part2=0
for x in "${input[@]}"; do
    stones "$x" 25
    (( part1 += STONES ))
    stones "$x" 75
    (( part2 += STONES ))
done

echo "part 1: $part1"
echo "part 2: $part2"
