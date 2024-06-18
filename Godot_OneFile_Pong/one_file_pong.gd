extends Control


const AI_SPEED : float = 280.0;
const PLAYER_SPEED : float = 300.0;
var ball_speed : float = 300.0;
const BALL_SPEED_GAME_START : float = 300.0;
const BALL_SPEED_PLAYER_BOUNCE_INCREASE : float = 20.0;

var ball_direction : Vector2 = Vector2.ZERO;
var ball_spawn_pos : Marker2D = null;
var ball_pos_player_score : float = 0.0;
var ball_pos_ai_score : float = 0.0;

var body_ball : CharacterBody2D;
var body_player : CharacterBody2D;
var body_ai : CharacterBody2D;

var score_player : int = 0;
var score_ai : int = 0;
var score_label : Label = null;


func _ready():
	ball_spawn_pos = get_node("Ball_Spawn_Pos");
	body_ball = get_node("Ball");
	body_player = get_node("Paddle_Player");
	body_ai = get_node("Paddle_AI");
	score_label = get_node("Score_Label");
	ball_pos_ai_score = get_node("AI_Win_Position").global_position.x;
	ball_pos_player_score = get_node("Player_Win_Position").global_position.x;
	
	randomize();
	
	spawn_ball();
	update_score_label();


func spawn_ball():
	ball_speed = BALL_SPEED_GAME_START;
	body_ball.global_position = ball_spawn_pos.global_position;
	var ball_horizontal_direction = 1;
	if (randf() >= 0.5):
		ball_horizontal_direction = -1;
	ball_direction = Vector2(ball_horizontal_direction, randf_range(-1, 1)).normalized();


func update_score_label():
	score_label.text = str(score_player) + " | " + str(score_ai);


func _physics_process(delta):
	process_ball_movement(delta);
	process_ai_movement(delta);
	process_player_movement(delta);

func process_ball_movement(delta):
	var ball_collision_info = body_ball.move_and_collide(ball_direction * ball_speed * delta);
	if (ball_collision_info != null and ball_collision_info.get_normal() != Vector2.ZERO):
		if (ball_collision_info.get_normal().x == 0):
			ball_direction.y = ball_collision_info.get_normal().y;
		elif (ball_collision_info.get_normal().y == 0):
			if (ball_collision_info.get_collider() == body_ai or ball_collision_info.get_collider() == body_player):
				ball_direction.x = ball_collision_info.get_normal().x;
				ball_direction.y = ball_collision_info.get_collider().global_position.direction_to(body_ball.global_position).y;
				ball_direction = ball_direction.normalized();
				ball_speed += BALL_SPEED_PLAYER_BOUNCE_INCREASE;
			else:
				ball_direction.x = ball_collision_info.normal.x;
		else:
			ball_direction = ball_collision_info.normal;
	
	if (body_ball.global_position.x < ball_pos_ai_score):
		score_ai += 1;
		update_score_label();
		spawn_ball();
	elif (body_ball.global_position.x > ball_pos_player_score):
		score_player += 1;
		update_score_label();
		spawn_ball();

func process_ai_movement(delta):
	var ai_to_ball_dir = body_ai.global_position.direction_to(body_ball.global_position);
	ai_to_ball_dir.x = 0;
	if (ai_to_ball_dir.y > 0.4 or ai_to_ball_dir.y > 0.4):
		if (ai_to_ball_dir != null):
			ai_to_ball_dir.y = 1;
		else:
			ai_to_ball_dir.y = -1;
	# warning-ignore:return_value_discarded
	print(ai_to_ball_dir)
	body_ai.move_and_collide(ai_to_ball_dir * AI_SPEED * delta);


func process_player_movement(delta):
	if (Input.is_action_pressed("ui_up")):
		# warning-ignore:return_value_discarded
		body_player.move_and_collide(Vector2.UP * PLAYER_SPEED * delta);
	elif (Input.is_action_pressed("ui_down")):
		# warning-ignore:return_value_discarded
		body_player.move_and_collide(Vector2.DOWN * PLAYER_SPEED * delta);
