extends Control

@onready var bottom_resize_control : Control = $Bottom
@onready var right_resize_control : Control = $Right
@onready var corner_resize_control : Control = $Corner
@onready var draggable_component = get_parent().find_child("DraggableComponent")

var resizing_node : Control
var resizing_flag := false:
    set(value):
        resizing_flag = value
        if value:
            EventBus.set_fullscreen_nopass_area()
        else:
            draggable_component.update_nopass_area()


func _process(_delta):
    if resizing_flag:
        if resizing_node in [bottom_resize_control, corner_resize_control]:
            get_parent().size.y = int(get_global_mouse_position().y - get_parent().global_position.y)
        if resizing_node in [right_resize_control, corner_resize_control]:
            get_parent().size.x = int(get_global_mouse_position().x - get_parent().global_position.x)
        draggable_component.update_nopass_area()


func gui_input_handling(event: InputEventMouseButton, node: Control):
    if event.button_index == MOUSE_BUTTON_LEFT:
        if not resizing_flag:
            resizing_node = node
        resizing_flag = event.is_pressed()


func _on_bottom_gui_input(event:InputEvent):
    if event is InputEventMouseButton:
        gui_input_handling(event, bottom_resize_control)


func _on_right_gui_input(event:InputEvent):
    if event is InputEventMouseButton:
        gui_input_handling(event, right_resize_control)


func _on_corner_gui_input(event:InputEvent):
    if event is InputEventMouseButton:
        gui_input_handling(event, corner_resize_control)
