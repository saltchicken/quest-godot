extends Node3D

@onready var label = get_node("Label3D")
@onready var text: String
@onready var timer = get_node("Timer")
@onready var y_offset = 0.25
@onready var x_offset = 0.0

#@onready var letter_per_second = 30.0

func _ready():
	position.y = y_offset
	timer.timeout.connect(_on_timer_timeout)
	# hide()
	# main()

func set_text(text_info: String):
	# text = text_info
	label.text = text_info

func type():
	#get_tree().paused = true
	#var lines = round((story_text[current_line].length()/1.0))
	#print("Lines: '%s'" %lines)
	#var time_length = round((story_text[current_line].length() / letter_per_second))
	#label.text = ""
	#label.visible_ratio = 0
	#var tween = create_tween()
	label.text = text
	start_timer() 
	#tween.tween_property(label, "visible_ratio", 1, time_length)
	#tween.set_trans(Tween.TRANS_LINEAR)
	#tween.tween_callback(start_timer)
		
		#panel.position.y -= lines * 2
		#panel.size.y = label.size.y + lines * 4 + 5
	#finish()
	
func main():
	# position.y -= y_offset
	# position.x += x_offset
	# show()
	# type()
	print("running main")
	start_timer()
		
func start_timer():
	timer.start()
	
func finish():
	hide()
	#get_tree().paused = false
	queue_free()
	#finished_dialogue.emit()
	
func _on_timer_timeout():
	#current_line += 1
	timer.stop()
	finish()
	#type()
