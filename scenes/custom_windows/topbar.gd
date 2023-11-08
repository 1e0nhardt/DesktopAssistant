extends PanelContainer


# func _on_minimize_button_pressed():
#     DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


# func _on_maximize_button_pressed():
#     match DisplayServer.window_get_mode():
#         DisplayServer.WINDOW_MODE_WINDOWED:
#             DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#         DisplayServer.WINDOW_MODE_FULLSCREEN:
#             DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_close_button_pressed():
    owner.queue_free()


