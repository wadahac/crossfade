extends TileMapLayer




func _on_player_transparent_tile(entry) -> void:
	if entry :
		self_modulate.a = 0.3
	elif not entry:
		self_modulate.a = 1

	
