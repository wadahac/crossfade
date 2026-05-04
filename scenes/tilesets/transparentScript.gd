extends TileMapLayer


var lerpfunc = false

func _on_player_transparent_tile(entry) -> void:
	if entry :
		lerpfunc = true
	elif not entry:
		lerpfunc = false

func _process(delta: float) -> void:
	if lerpfunc:
		modulate.a = lerp(modulate.a, 0.3, delta * 5)
	elif not lerpfunc:
		modulate.a = lerp(modulate.a, 1.0, delta * 5)
