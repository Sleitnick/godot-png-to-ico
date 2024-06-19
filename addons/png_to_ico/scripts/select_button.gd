@tool
extends Button


signal files_selected(paths: PackedStringArray)


const ImageFileDialogPrefab = preload("res://addons/png_to_ico/scenes/image_file_dialog.tscn")


var _dialog: FileDialog


func _ready():
	pass


func _exit_tree():
	if _dialog:
		_dialog.queue_free()
		_dialog = null


func _on_pressed():
	_dialog = ImageFileDialogPrefab.instantiate() as FileDialog
	
	_dialog.close_requested.connect(func() -> void:
		_dialog.queue_free()
		_dialog = null
	)
	
	_dialog.files_selected.connect(func(paths: PackedStringArray) -> void:
		files_selected.emit(paths)
		_dialog.queue_free()
		_dialog = null
	)
	
	get_tree().root.add_child(_dialog)
	_dialog.show()
