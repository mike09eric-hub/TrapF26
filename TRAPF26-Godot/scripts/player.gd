extends CharacterBody3D
class_name TrapfPlayer

@export var move_speed: float = 5.2
@export var sprint_speed: float = 7.4
@export var acceleration: float = 18.0
@export var is_user: bool = false
@export var team_id: int = 0

var stamina: float = 100.0
var has_ball: bool = false
var home_position: Vector3
var body_mesh: MeshInstance3D
var facing := Vector3.FORWARD

func _ready() -> void:
	_build_visual()
	home_position = global_position

func _build_visual() -> void:
	var kit := StandardMaterial3D.new()
	kit.albedo_color = Color(0.035, 0.28, 0.82) if team_id == 0 else Color(0.78, 0.055, 0.09)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.55, 0.34, 0.23)
	var shorts_mat := StandardMaterial3D.new()
	shorts_mat.albedo_color = Color(0.025, 0.08, 0.2) if team_id == 0 else Color(0.22, 0.025, 0.035)
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.27
	torso_mesh.height = 0.9
	torso.mesh = torso_mesh
	torso.position.y = 1.25
	torso.material_override = kit
	add_child(torso)
	body_mesh = torso
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.17
	head_mesh.height = 0.34
	head.mesh = head_mesh
	head.position.y = 1.92
	head.material_override = skin
	add_child(head)
	var shorts := MeshInstance3D.new()
	var shorts_mesh := BoxMesh.new()
	shorts_mesh.size = Vector3(0.48, 0.32, 0.28)
	shorts.mesh = shorts_mesh
	shorts.position.y = 0.72
	shorts.material_override = shorts_mat
	add_child(shorts)
	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := CapsuleMesh.new()
		leg_mesh.radius = 0.095
		leg_mesh.height = 0.7
		leg.mesh = leg_mesh
		leg.position = Vector3(side * 0.14, 0.35, 0.0)
		leg.material_override = skin
		add_child(leg)

func user_move(input_vector: Vector2, delta: float, sprint_requested: bool) -> void:
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	var sprinting := sprint_requested and stamina > 1.0 and direction.length() > 0.1
	if sprinting:
		stamina = maxf(0.0, stamina - 24.0 * delta)
	else:
		stamina = minf(100.0, stamina + 12.0 * delta)
	var target_speed := sprint_speed if sprinting else move_speed
	velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
	if direction.length() > 0.08:
		facing = direction.normalized()
		look_at(global_position + facing, Vector3.UP)
	move_and_slide()

func reset_to_home() -> void:
	global_position = home_position
	velocity = Vector3.ZERO
