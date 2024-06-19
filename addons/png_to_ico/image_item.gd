@tool
class_name ImageItem
extends HBoxContainer


@onready var _texture_rect: TextureRect = $"TextureRect"
@onready var _label: Label = $"Label"


var _image_path := ""
var _timer: Timer = null


var image_buffer: PackedByteArray
var image_size := Vector2.ZERO
var valid := false


static func _load_image_path_to_buffer(path: String) -> PackedByteArray:
	var file := FileAccess.open(path, FileAccess.READ)
	if FileAccess.get_open_error() != OK:
		push_error("Failed to load image: %s" % error_string(FileAccess.get_open_error()))
		return PackedByteArray([])
	
	var buffer := file.get_buffer(file.get_length())
	file.close()
	
	return buffer


static func _load_image_texture_from_buffer(buf: PackedByteArray) -> ImageTexture:
	var image := Image.new()
	var err := image.load_png_from_buffer(buf)
	if err != OK:
		push_error("Failed to load PNG from buffer: %s" % error_string(err))
		return null
	
	return ImageTexture.create_from_image(image)


func _on_set():
	if _timer:
		_timer.queue_free()
		_timer = null
	
	if _image_path == "" or (not _texture_rect) or (not _label):
		return
	
	# Load image:
	image_buffer = ImageItem._load_image_path_to_buffer(_image_path)
	var image := ImageItem._load_image_texture_from_buffer(image_buffer)
	_texture_rect.texture = image
	
	var texture_size := image.get_size()
	image_size = texture_size
	var filename := _image_path
	var last_slash_idx := filename.rfind("/")
	if last_slash_idx != -1:
		filename = filename.substr(last_slash_idx + 1)
	_label.text = "[%d] %s" % [texture_size.x, filename]
	
	valid = texture_size.x == texture_size.y and texture_size.x <= 256
	if valid:
		_label.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		_label.add_theme_color_override("font_color", Color(1, 0, 0))


func _ready():
	_on_set()


func set_image(image_path: String) -> void:
	_image_path = image_path
	_on_set()
