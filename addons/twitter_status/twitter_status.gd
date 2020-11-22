tool
extends EditorPlugin

var dock : Control

func _enter_tree():
	dock = preload("res://addons/twitter_status/twitter_dock/twitter_dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()
