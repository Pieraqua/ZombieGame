extends GPUParticles3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !emitting:
		queue_free()
