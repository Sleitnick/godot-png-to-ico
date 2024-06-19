@tool
extends EditorPlugin


const ICOMain: PackedScene = preload("res://addons/png_to_ico/scenes/ico_main.tscn")
const Title := "PNG to ICO"
const Icon := "ImageTexture"


var _ico_main_instance: Control


func _enter_tree() -> void:
	_ico_main_instance = ICOMain.instantiate() as Control
	EditorInterface.get_editor_main_screen().add_child(_ico_main_instance)
	_make_visible(false)


func _exit_tree() -> void:
	if _ico_main_instance:
		_ico_main_instance.queue_free()
		_ico_main_instance = null


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return Title


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon(Icon, "EditorIcons")


func _make_visible(visible) -> void:
	if _ico_main_instance:
		_ico_main_instance.visible = visible
