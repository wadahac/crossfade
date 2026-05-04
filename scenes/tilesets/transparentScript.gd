extends TileMapLayer


var lerpfunc = false

func _on_player_transparent_tile(entry,whatEntered,inFront) -> void:
	print("recieved")
	if whatEntered.name == self.name and inFront:
		print("it passed")
		if entry :
			lerpfunc = true
			print("was set to true")
		elif not entry:
			lerpfunc = false
			print("was set to false")

func _process(delta: float) -> void:
	if lerpfunc:
		modulate.a = lerp(modulate.a, 0.3, delta * 8)
	elif not lerpfunc:
		modulate.a = lerp(modulate.a, 1.0, delta * 8)
