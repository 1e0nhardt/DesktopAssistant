extends Node


func _enter_tree():
    # 在子节点_ready()前先全屏
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)