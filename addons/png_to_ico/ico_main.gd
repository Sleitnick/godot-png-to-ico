@tool
extends Control


@export var _image_item_prefab: PackedScene
@export var _export_image_dialog_prefab: PackedScene


var _image_items: Array[ImageItem] = []


@onready var _export_btn: Button = $"VBoxContainer/ExportButton"
@onready var _images_container: VBoxContainer = $"VBoxContainer/ImagesContainer"


func _ready():
	_export_btn.disabled = true


func _on_export_button_pressed() -> void:
	var dialog := _export_image_dialog_prefab.instantiate() as FileDialog
	dialog.close_requested.connect(func() -> void:
		dialog.queue_free()
	)
	dialog.file_selected.connect(func(filepath: String) -> void:
		dialog.queue_free()
		ICOGenerator.generate(filepath, _image_items)
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
