package main

import "core:c"
import rl "vendor:raylib"

WIN_WIDTH :: 600
WIN_HEIGHT :: 600
PADDLE_WIDTH :: 120
PADDLE_HEIGHT :: 20
PADDLE_SPEED :: 10
BALL_SIZE :: 20

player_x, player_y: c.int = WIN_WIDTH / 2 - PADDLE_WIDTH / 2, WIN_HEIGHT - PADDLE_HEIGHT * 2
bot_x, bot_y: c.int = WIN_WIDTH / 2 - PADDLE_WIDTH / 2, PADDLE_HEIGHT * 2
ball_x, ball_y: c.int = rl.GetRandomValue(0, WIN_WIDTH - BALL_SIZE), rl.GetRandomValue(0, WIN_HEIGHT - BALL_SIZE)
dx, dy: c.int = 1, 1
vel_x, vel_y: c.int = 8, 8

change_ball_direction :: proc() {
    if ball_x + BALL_SIZE > WIN_WIDTH || ball_x < 0 {
        dx *= -1
    }
    if ball_y + BALL_SIZE > WIN_HEIGHT || ball_y < 0 {
        dy *= -1
    }

    // Paddles
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

        change_ball_direction()

        rl.EndDrawing()
    }
}