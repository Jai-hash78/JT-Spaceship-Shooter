extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_z_index(5)


func _on_animated_sprite_2d_animation_finished():
	queue_free()
