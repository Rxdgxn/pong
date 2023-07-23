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
ball_x, ball_y: c.int
dx, dy: c.int = rand.choice(dirs), -1
vel_x, vel_y: c.int = 8, 8
particles: [dynamic]Particle
launched := false
dirs := []c.int{-1, 1}

set_random :: proc() {
    ball_x += dx * vel_x
    ball_y += dy * vel_y
    vel_x, vel_y = rl.GetRandomValue(7, 9), rl.GetRandomValue(7, 9)
}

change_ball_direction :: proc() {
    // Walls
    if launched {
        if ball_x + BALL_SIZE > WIN_WIDTH {
            add_particles(-1)
            dx *= -1
        }
        if ball_x < 0 {
            add_particles(1)
            dx *= -1
        }
        if ball_y + BALL_SIZE > WIN_HEIGHT || ball_y < 0 {
            ball_x, ball_y = rl.GetRandomValue(0, WIN_WIDTH - BALL_SIZE), WIN_HEIGHT / 2 + BALL_SIZE / 2
            launched = false
            dx = rand.choice(dirs)
            set_random()
        }
        // Paddles
        if ball_y + BALL_SIZE >= player_y && ball_x >= player_x && ball_x + 1 <= player_x + PADDLE_WIDTH {
            add_particles(rand.choice(dirs))
            dy *= -1
            set_random()
        }
        if ball_y <= bot_y + PADDLE_HEIGHT && ball_x >= bot_x && ball_x + 1 <= bot_x + PADDLE_WIDTH {
            add_particles(rand.choice(dirs))
            dy *= -1
            set_random()
        }
    }
}

add_particles :: proc(d_x: c.int) {
    colors := []rl.Color {rl.WHITE, rl.YELLOW, rl.GRAY, rl.BLUE, rl.LIME, rl.LIGHTGRAY, rl.RED}
    for i in 0 ..< P_COUNT {
        append(&particles, Particle {ball_x, ball_y, d_x, rand.choice(dirs), rl.GetRandomValue(1, 5), rl.GetRandomValue(1, 5), rand.choice(colors)})
    }
}

main :: proc() {

    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Pong")
    rl.SetTargetFPS(40)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        rl.DrawRectangle(player_x, player_y, PADDLE_WIDTH, PADDLE_HEIGHT, rl.WHITE)
        rl.DrawRectangle(bot_x, bot_y, PADDLE_WIDTH, PADDLE_HEIGHT, rl.WHITE)
        rl.DrawRectangle(ball_x, ball_y, BALL_SIZE, BALL_SIZE, rl.WHITE)

        if rl.IsKeyDown(rl.KeyboardKey.A) {
            if player_x > 0 do player_x -= PADDLE_SPEED
        }
        else if rl.IsKeyDown(rl.KeyboardKey.D) {
            if player_x + PADDLE_WIDTH < WIN_WIDTH do player_x += PADDLE_SPEED
        }

        if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
            launched = true
        }
        
        if launched {
            ball_x += dx * vel_x
            ball_y += dy * vel_y
        }
        else {
            ball_x = player_x + PADDLE_WIDTH / 2 - BALL_SIZE / 2
            ball_y = player_y - BALL_SIZE - 1
        }

        if ball_x + PADDLE_WIDTH / 2 < WIN_WIDTH && ball_x > 0 {
            bot_x = ball_x - PADDLE_WIDTH / 2 + BALL_SIZE / 2
        }

        change_ball_direction()

        for i in 0 ..< len(particles) {
            rl.DrawRectangle(particles[i].x, particles[i].y, 10, 10, particles[i].color)
            particles[i].x += particles[i].dx * particles[i].vel_x
            particles[i].y += particles[i].dy * particles[i].vel_y
        }

        for i in 0 ..< len(particles) {
            if (particles[i].x < 0 || particles[i].x > WIN_WIDTH || particles[i].y < 0 || particles[i].y > WIN_HEIGHT) {
                ordered_remove(&particles, i)
            }
        }
        
        rl.EndDrawing()
    }

    delete(particles)
    rl.CloseWindow()
}