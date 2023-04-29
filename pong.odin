package main

import "core:fmt"
import la "core:math/linalg"
import math "core:math/linalg/hlsl"
import rl "vendor:raylib"
import rand "core:math/rand"
import "core:strings"

Ball :: struct {
	p : math.float2,
	velocity : math.float2,
}

Paddle :: struct {
	p : math.float2,
	score : int,
	dim : math.int2,
}

player1 : Paddle
player2 : Paddle

ball : Ball


main :: proc(){
	fmt.println("yooo")

	window_dim := math.int2{800, 600}
	rl.InitWindow(window_dim.x, window_dim.y, "pong")
	rl.SetTargetFPS(60)
	rl.SetWindowTitle("Pong")
	is_running := true	

	player1.p = math.float2{100.0, f32(window_dim.y/2)}
	player2.p = math.float2{f32(window_dim.x - 100.0), f32(window_dim.y/2)}

	player1.dim = math.int2{10, 80}
	player2.dim = math.int2{10, 80}

	ball.p = {f32(window_dim.x/2), f32(window_dim.y/2)}

	current_speed :f32 = 15.0
	ball.velocity = math.float2{rand.float32_normal(0,1), rand.float32_normal(0,1)}

	for is_running && !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		// ball position based on its velocity
		ball.p += (ball.velocity * current_speed)
		
		//ball collision with wall
		if ball.p.x < 0 {
			ball.p.x = 0
			ball.velocity.x = -ball.velocity.x
		}else if ball.p.x > f32(window_dim.x) {
			ball.p.x = f32(window_dim.x)
			ball.velocity.x = -ball.velocity.x
		}else if ball.p.y < 0 {
			ball.p.y = 0
			ball.velocity.y = -ball.velocity.y
		}else if ball.p.y > f32(window_dim.y) {
			ball.p.y = f32(window_dim.y)
			ball.velocity.y = -ball.velocity.y
		}

		//paddle movements
		if rl.IsKeyDown(rl.KeyboardKey.W) {
			player1.p.y -= current_speed
		} else if rl.IsKeyDown(rl.KeyboardKey.S) {
			player1.p.y += current_speed
		}
		if rl.IsKeyDown(rl.KeyboardKey.UP) {
			player2.p.y -= current_speed
		} else if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
			player2.p.y += current_speed
		}

		//ball collision with paddle
		paddle_ball_collision_detection(&ball,player1)
		paddle_ball_collision_detection(&ball,player2)

		//paddle movements on boundary
		if player1.p.y > f32(window_dim.y){
			player1.p.y = 0
		} else if player1.p.y < f32(0){
			player1.p.y = f32(window_dim.y)
		}
		if player2.p.y > f32(window_dim.y){
			player2.p.y = 0
		} else if player2.p.y < f32(0){
			player2.p.y = f32(window_dim.y)
		}


		//Draw paddle and ball
		rl.DrawRectangle(i32(player1.p.x), i32(player1.p.y), player1.dim.x, player1.dim.y, rl.WHITE)
		rl.DrawRectangle(i32(player2.p.x), i32(player2.p.y), player2.dim.x, player2.dim.y, rl.WHITE)
		rl.DrawRectangle(i32(ball.p.x), i32(ball.p.y), 10, 10, rl.WHITE)
		rl.EndDrawing()


		//scoring system
		if ball.p.x <= 0{
			player2.score += 1
		}else if ball.p.x >= f32(window_dim.x){
			player1.score += 1
		}

		player1_score := strings.clone_to_cstring(fmt.tprintf("P1  %v",player1.score),context.temp_allocator)
		rl.DrawText(player1_score, 100, 100, 20, rl.DARKGRAY)

		player2_score := strings.clone_to_cstring(fmt.tprintf("P2  %v",player2.score),context.temp_allocator)
		rl.DrawText(player2_score, window_dim.x - 100, 100, 20, rl.DARKGRAY)

	}
}

paddle_ball_collision_detection :: proc(ball : ^Ball, paddle : Paddle){
	//ball collision with paddle
	//NOTE(RAY):This is not going to handle the case 
	//where the ball is hitting the top and bottom of the paddle
	if ball.p.x < paddle.p.x + f32(paddle.dim.x) && 
	ball.p.x > paddle.p.x - f32(paddle.dim.x) && 
	ball.p.y < paddle.p.y + f32(paddle.dim.y) && 
	ball.p.y > paddle.p.y - f32(paddle.dim.y){
		ball.velocity.x = -ball.velocity.x
		fmt.println("collision with player1")
	}
}
