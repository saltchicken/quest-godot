extends AnimationTree

func play(anim_name):
	get("parameters/playback").travel(anim_name)
	
func set_direction(anim_name, direction):
	set("parameters/" + anim_name + "/BlendSpace2D/blend_position", direction)

func set_speed_scale(anim_name, speed_scale):
	set("parameters/" + anim_name + "/TimeScale/scale", speed_scale)
