extends RigidBody3D
class_name TrapfBall

var owner_player: TrapfPlayer
var radius := 0.22

func _ready() -> void:
	mass = 0.43
	gravity_scale = 1.0
	linear_damp = 0.22
	angular_damp = 0.35
	continuous_cd = true
	var shape := SphereShape3D.new()
	shape.radius = radius
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)
	var visual := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	visual.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.94, 0.94, 0.9)
	mat.roughness = 0.62
	visual.material_override = mat
	add_child(visual)

func kick(direction: Vector3, power: float) -> void:
	owner_player = null
	apply_central_impulse(direction.normalized() * power)
