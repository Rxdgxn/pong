package main

import "core:fmt"
import "core:c"
import "core:math/rand"
import rl "vendor:raylib"

WIN_WIDTH :: 600
WIN_HEIGHT :: 600
PADDLE_WIDTH :: 120
PADDLE_HEIGHT :: 20
PADDLE_SPEED :: 10
BALL_SIZE :: 20
P_COUNT :: 5

Particle :: struct {
    x, y, vel_x, vel_y, dx, dy: c.int,
    color: rl.Color,
}

player_x, player_y: c.int = WIN_WIDTH / 2 - PADDLE_WIDTH / 2, WIN_HEIGHT - PADDLE_HEIGHT * 2
bot_x, bot_y: c.int = WIN_WIDTH / 2 - PADDLE_WIDTH / 2, PADDLE_HEIGHT
ball_x, ball_y: c.int = rl.GetRandomValue(0, WIN_WIDTH - BALL_SIZE), WIN_HEIGHT / 2 + BALL_SIZE / 2
dx, dy: c.int = 1, 1
vel_x, vel_y: c.int = 8, 8
particles: [dynamic]Particle

change_ball_direction :: proc() {
    // Walls
    if ball_x + BALL_SIZE > WIN_WIDTH || ball_x < 0 {
        add_particles()
        dx *= -1
    }
    if ball_y + BALL_SIZE > WIN_HEIGHT || ball_y < 0 {
        ball_x, ball_y = rl.GetRandomValue(0, WIN_WIDTH - BALL_SIZE), WIN_HEIGHT / 2 + BALL_SIZE / 2
    }
    // Paddles
    if ball_y + BALL_SIZE >= player_y && ball_x >= player_x && ball_x + 1 <= player_x + PADDLE_WIDTH {
        add_particles()
        dy *= -1
    }
    if ball_y <= bot_y + PADDLE_HEIGHT && ball_x >= bot_x && ball_x + 1 <= bot_x + PADDLE_WIDTH {
        add_particles()
        dy *= -1
    }
}

add_particles :: proc() {
    colors := []rl.Color {rl.WHITE, rl.YELLOW, rl.GRAY, rl.BLUE, rl.LIME, rl.LIGHTGRAY, rl.RED}
    dirs := []c.int {-1, 1}
    for i in 0 ..< P_COUNT {
        append(&particles, Particle {ball_x, ball_y, rand.choice(dirs), rand.choice(dirs), rl.GetRandomValue(1, 3), rl.GetRandomValue(1, 3), rand.choice(colors)})
    }
}

main :: proc() {

    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Pong")
    defer rl.CloseWindow()
    rl.SetTargetFPS(30)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        rl.DrawRectangle(player_x, player_y, PADDLE_WIDTH, PADDLE_HEIGHT, rl.WHITE)
        rl.DrawRectangle(bot_x, bot_y, PADDLE_WIDTH, PADDLE_HEIGHT, rl.WHITE)
        rl.DrawRectangle(ball_x, ball_y, BALL_SIZE, BALL_SIZE, rl.WHITE)

        if rl.IsKeyDown(rl.KeyboardKey.A) {
            player_x -= PADDLE_SPEED
        }
        else if rl.IsKeyDown(rl.KeyboardKey.D) {
            player_x += PADDLE_SPEED
        }

        ball_x += dx * vel_x
        ball_y += dy * vel_y

        if ball_x + PADDLE_WIDTH < WIN_WIDTH + BALL_SIZE / 2 {
            bot_x = ball_x
        }

        change_ball_direction()

        for i in 0 ..< len(particles) {
            rl.DrawRectangle(particles[i].x, particles[i].y, 10, 10, particles[i].color)
            particles[i].x += particles[i].dx * particles[i].vel_x
            particles[i].y += particles[i].dy * particles[i].vel_y
        }

        if len(particles) > P_COUNT * 5 {
            for i in 0 ..< P_COUNT {
                ordered_remove(&particles, 0)
            }
        }
        
        rl.EndDrawing()
    }

    delete(particles)
}