@tool
extends PanelContainer


@export var _image_item_prefab: PackedScene
@export var _export_image_dialog_prefab: PackedScene


var _image_items: Array[ImageItem] = []


@onready var _export_btn: Button = %"ExportButton"
@onready var _images_container: VBoxContainer = %"ImagesContainer"


func _ready():
	_export_btn.disabled = true


func _show_status_dialog(title: String, message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	get_tree().root.add_child(dialog)
	dialog.call_deferred("show")


func _on_export_button_pressed() -> void:
	var dialog := _export_image_dialog_prefab.instantiate() as FileDialog
	dialog.close_requested.connect(func() -> void:
		dialog.queue_free()
	)
	dialog.file_selected.connect(func(filepath: String) -> void:
		dialog.queue_free()
		var gen_err := ICOGenerator.generate(filepath, _image_items)
		if gen_err == OK:
			_show_status_dialog("Export Successful", "Export successful: %s" % filepath)
		else:
			_show_status_dialog("Export Failed", "Failed to export file: %s" % error_string(gen_err))
	)
	get_tree().root.add_child(dialog)
	dialog.show()


func _on_select_button_files_selected(paths: PackedStringArray) -> void:
	_export_btn.disabled = paths.size() == 0
	
	# Clear images container:
	for child in _images_container.get_children():
		child.queue_free()
	
	# Add image items:
	_image_items = []
	for path in paths:
		var item := _image_item_prefab.instantiate() as ImageItem
		item.set_image(path)
		_image_items.append(item)
	
	# Sort smallest-to-largest images:
	_image_items.sort_custom(func(a: ImageItem, b: ImageItem) -> bool:
		return a.image_size.x < b.image_size.x
	)
	
	# Add image items into scene:
	for image_item in _image_items:
		_images_container.add_child(image_item)
