extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const BALL_SCRIPT = preload("res://scripts/ball.gd")

var user_player: TrapfPlayer
var match_ball: TrapfBall
var match_seconds := 0.0
var home_goals := 0
var away_goals := 0
var match_running := false
var camera: Camera3D
var score_label: Label
var stamina_bar: ProgressBar

func _ready() -> void:
	_build_world()
	_build_hud()
	_spawn_teams()
	_spawn_ball()
	_build_camera()
	match_running = true

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65, 0.72, 0.8)
	env.ambient_light_energy = 0.8
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.25
	add_child(sun)
	var turf := StandardMaterial3D.new()
	turf.albedo_color = Color(0.075, 0.36, 0.13)
	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(70, 108)
	ground.mesh = ground_mesh
	ground.material_override = turf
	add_child(ground)
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(70, 0.3, 108)
	collision.shape = floor_shape
	collision.position.y = -0.2
	body.add_child(collision)
	add_child(body)
	_add_pitch_markings()

func _add_pitch_markings() -> void:
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.92, 0.95, 0.9)
	_line(Vector3(0, 0.025, -52), Vector3(0, 0.025, 52), 0.12, white)
	_line(Vector3(-34, 0.025, 0), Vector3(34, 0.025, 0), 0.12, white)
	_line(Vector3(-34, 0.025, -52), Vector3(34, 0.025, -52), 0.12, white)
	_line(Vector3(-34, 0.025, 52), Vector3(34, 0.025, 52), 0.12, white)
	_line(Vector3(-34, 0.025, -52), Vector3(-34, 0.025, 52), 0.12, white)
	_line(Vector3(34, 0.025, -52), Vector3(34, 0.025, 52), 0.12, white)
	var circle := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 8.8
	torus.outer_radius = 9.0
	circle.mesh = torus
	circle.position.y = 0.04
	circle.material_override = white
	add_child(circle)

func _line(a: Vector3, b: Vector3, width: float, mat: Material) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(width, 0.035, a.distance_to(b))
	mesh.mesh = box
	mesh.position = (a + b) * 0.5
	mesh.look_at(b, Vector3.UP)
	mesh.material_override = mat
	add_child(mesh)

func _spawn_teams() -> void:
	var home := [Vector3(0,0,44),Vector3(-25,0,30),Vector3(-9,0,32),Vector3(9,0,32),Vector3(25,0,30),Vector3(-17,0,12),Vector3(0,0,15),Vector3(17,0,12),Vector3(-13,0,-12),Vector3(0,0,-17),Vector3(13,0,-12)]
	var away := []
	for p in home:
		away.append(Vector3(p.x, 0, -p.z))
	for i in range(11):
		var p: TrapfPlayer = PLAYER_SCRIPT.new()
		p.team_id = 0
		p.is_user = i == 9
		p.position = home[i]
		add_child(p)
		if i == 9:
			user_player = p
		var opponent: TrapfPlayer = PLAYER_SCRIPT.new()
		opponent.team_id = 1
		opponent.position = away[i]
		add_child(opponent)

func _spawn_ball() -> void:
	match_ball = BALL_SCRIPT.new()
	match_ball.position = Vector3(0, 0.35, 0)
	add_child(match_ball)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 72.0
	add_child(camera)
	camera.position = Vector3(0, 8, 11)
	camera.look_at(user_player.global_position, Vector3.UP)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 12)
	panel.size = Vector2(250, 48)
	layer.add_child(panel)
	score_label = Label.new()
	score_label.text = "TRAPF 26     0 - 0     00:00"
	panel.add_child(score_label)
	stamina_bar = ProgressBar.new()
	stamina_bar.position = Vector2(16, 66)
	stamina_bar.size = Vector2(180, 16)
	stamina_bar.max_value = 100
	stamina_bar.value = 100
	layer.add_child(stamina_bar)
	_add_hold_button(layer, "UP", Vector2(90, -150), "move_forward", Vector2(58, 58))
	_add_hold_button(layer, "DOWN", Vector2(90, -38), "move_back", Vector2(58, 58))
	_add_hold_button(layer, "LEFT", Vector2(26, -94), "move_left", Vector2(58, 58))
	_add_hold_button(layer, "RIGHT", Vector2(154, -94), "move_right", Vector2(58, 58))
	_add_hold_button(layer, "SPRINT", Vector2(-190, -90), "sprint", Vector2(86, 58))
	_add_action_button(layer, "PASS", Vector2(-190, -154), "pass_ball")
	_add_action_button(layer, "SHOOT", Vector2(-96, -154), "shoot_ball")

func _add_hold_button(layer: CanvasLayer, caption: String, offset: Vector2, action: String, button_size: Vector2) -> void:
	var button := Button.new()
	button.text = caption
	button.size = button_size
	button.anchor_left = 0.0
	button.anchor_top = 1.0
	button.anchor_right = 0.0
	button.anchor_bottom = 1.0
	button.position = offset
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	layer.add_child(button)

func _add_action_button(layer: CanvasLayer, caption: String, offset: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = caption
	button.size = Vector2(82, 62)
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.position = offset
	button.pressed.connect(func():
		Input.action_press(action)
		Input.action_release(action)
	)
	layer.add_child(button)

func _process(delta: float) -> void:
	if not match_running or user_player == null:
		return
	match_seconds += delta
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	user_player.user_move(input_vector, delta, Input.is_action_pressed("sprint"))
	stamina_bar.value = user_player.stamina
	camera.position = camera.position.lerp(user_player.global_position + Vector3(0, 7, 10), delta * 3.0)
	camera.look_at(user_player.global_position + Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("shoot_ball"):
		_shoot()
	if Input.is_action_just_pressed("pass_ball"):
		_pass()
	score_label.text = "TRAPF 26     %d - %d     %02d:%02d" % [home_goals, away_goals, int(match_seconds) / 60, int(match_seconds) % 60]

func _shoot() -> void:
	if user_player.global_position.distance_to(match_ball.global_position) < 2.5:
		var direction := -user_player.global_transform.basis.z
		match_ball.kick(direction + Vector3(0, 0.14, 0), 11.0)

func _pass() -> void:
	if user_player.global_position.distance_to(match_ball.global_position) < 2.5:
		var direction := -user_player.global_transform.basis.z
		match_ball.kick(direction + Vector3(0, 0.04, 0), 5.0)
