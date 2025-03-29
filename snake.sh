#!/bin/bash

# Initialize game variables
width=20
height=10
snake_x=5
snake_y=5
direction="RIGHT"
fruit_x=$((RANDOM % width))
fruit_y=$((RANDOM % height))
score=0
game_over=false
snake_body=("$snake_x,$snake_y")
tail_length=1

# Hide cursor and clear screen
tput civis
clear

# Function to draw the game board
draw_board() {
    clear
    echo "Score: $score"
    echo "Use arrow keys to move, Q to quit"
    
    # Draw top border
    printf '+'
    for ((i=0; i<width; i++)); do printf '-'; done
    printf '+\n'

    # Draw game area
    for ((y=0; y<height; y++)); do
        printf '|'
        for ((x=0; x<width; x++)); do
            if [ "$x" -eq "$fruit_x" ] && [ "$y" -eq "$fruit_y" ]; then
                printf 'F'
            else
                is_snake=false
                for pos in "${snake_body[@]}"; do
                    if [ "$pos" == "$x,$y" ]; then
                        if [ "$x" -eq "$snake_x" ] && [ "$y" -eq "$snake_y" ]; then
                            printf 'O'  # Snake head
                        else
                            printf 'o'  # Snake body
                        fi
                        is_snake=true
                        break
                    fi
                done
                if [ "$is_snake" = false ]; then
                    printf ' '
                fi
            fi
        done
        printf '|\n'
    done

    # Draw bottom border
    printf '+'
    for ((i=0; i<width; i++)); do printf '-'; done
    printf '+\n'
}

# Function to move snake
move_snake() {
    # Store previous head position
    prev_x=$snake_x
    prev_y=$snake_y

    # Move head
    case $direction in
        "UP") ((snake_y--));;
        "DOWN") ((snake_y++));;
        "LEFT") ((snake_x--));;
        "RIGHT") ((snake_x++));;
    esac

    # Check boundaries
    if [ $snake_x -ge $width ] || [ $snake_x -lt 0 ] || [ $snake_y -ge $height ] || [ $snake_y -lt 0 ]; then
        game_over=true
        return
    fi

    # Update snake body
    new_body=("$snake_x,$snake_y")
    for ((i=0; i<tail_length-1; i++)); do
        new_body+=("${snake_body[$i]}")
    done
    snake_body=("${new_body[@]}")

    # Check if snake ate fruit
    if [ "$snake_x" -eq "$fruit_x" ] && [ "$snake_y" -eq "$fruit_y" ]; then
        ((score+=10))
        ((tail_length++))
        fruit_x=$((RANDOM % width))
        fruit_y=$((RANDOM % height))
    fi

    # Check self-collision
    for ((i=1; i<${#snake_body[@]}; i++)); do
        if [ "${snake_body[0]}" == "${snake_body[$i]}" ]; then
            game_over=true
            return
        fi
    done
}

# Function to read input
read_input() {
    read -s -t 0.1 -n 3 key
    case "$key" in
        $'\e[A') direction="UP";;
        $'\e[B') direction="DOWN";;
        $'\e[D') direction="LEFT";;
        $'\e[C') direction="RIGHT";;
        "q"|"Q") game_over=true;;
    esac
}

# Main game loop
while [ "$game_over" = false ]; do
    draw_board
    read_input
    move_snake
    sleep 0.1
done

# Game over
clear
echo "Game Over!"
echo "Final Score: $score"
tput cnorm  # Show cursor
