@tool
class_name ImageItem
extends HBoxContainer


var image_buffer: PackedByteArray
var image_size := Vector2.ZERO
var valid := false


var _image_path := ""
var _timer: Timer = null


@onready var _texture_rect: TextureRect = $"TextureRect"
@onready var _filename_label: Label = $"VBoxContainer/FilenameLabel"
@onready var _size_label: Label = $"VBoxContainer/SizeLabel"


func _ready():
	_on_set()


func set_image(image_path: String) -> void:
	_image_path = image_path
	_on_set()


func _on_set():
	if _timer:
		_timer.queue_free()
		_timer = null
	
	if _image_path == "" or (not _texture_rect):
		return
	
	# Load image:
	image_buffer = _load_image_path_to_buffer(_image_path)
	var image := _load_image_texture_from_buffer(image_buffer)
	_texture_rect.texture = image
	
	# Filename and dimensions:
	var texture_size := image.get_size()
	image_size = texture_size
	var filename := _image_path
	var last_slash_idx := filename.rfind("/")
	if last_slash_idx != -1:
		filename = filename.substr(last_slash_idx + 1)
	_filename_label.text = filename
	_size_label.text = "%dx%d" % [texture_size.x, texture_size.y]
	
	valid = texture_size.x == texture_size.y and texture_size.x <= 256
	if valid:
		_filename_label.remove_theme_color_override("font_color")
	else:
		_filename_label.add_theme_color_override("font_color", Color(1, 0, 0))


func _load_image_path_to_buffer(path: String) -> PackedByteArray:
	var file := FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		push_error("Failed to load image: %s" % error_string(FileAccess.get_open_error()))
		return PackedByteArray([])
	
	var buffer := file.get_buffer(file.get_length())
	file.close()
	
	return buffer


func _load_image_texture_from_buffer(buf: PackedByteArray) -> ImageTexture:
	var image := Image.new()
	var err := image.load_png_from_buffer(buf)
	if err != OK:
		push_error("Failed to load PNG from buffer: %s" % error_string(err))
		return null
	
	return ImageTexture.create_from_image(image)
