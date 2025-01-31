extends Area2D

@export var speed = -750 
@export var explosionObj: PackedScene

func _process(delta):
	position += transform.y * speed * delta



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit()
		var ex = explosionObj.instantiate()
		ex.position = self.global_position
		ex.rotation = self.global_rotation
		get_parent().add_child(ex)
		queue_free()
