extends AnimationTree

func play(anim_name):
	get("parameters/playback").travel(anim_name)
	
func set_direction(anim_name, direction):
	set("parameters/" + anim_name + "/BlendSpace2D/blend_position", direction)
