extends Camera3D

@onready var raycast = $RayCast3D

func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target.get_parent().has_method("die"):
			target.get_parent().die()
