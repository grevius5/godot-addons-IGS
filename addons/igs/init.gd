tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("IGS", "Node", preload("res://addons/igs/IGS.gd"), preload("res://addons/igs/icon.png"))


func _exit_tree():
	remove_custom_type("IGS")
