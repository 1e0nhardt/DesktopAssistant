extends VBoxContainer

const area_offset = 1

@onready var todo_widget = preload("res://scenes/custom_windows/todo_window.tscn")

var todo_widget_activated := false
var todo_widget_instance: TodoWidget


func update_nopass_area():
    # 全屏后新位置要在pet节点ready后获取其新设置的位置
    var nopass_area = PackedVector2Array([
        global_position - Vector2(area_offset, area_offset),
        global_position + Vector2(get_rect().size.x + area_offset, -area_offset),
        global_position + get_rect().size + Vector2(area_offset, area_offset),
        global_position + Vector2(-area_offset, get_rect().size.y + area_offset)
    ])
    EventBus.update_nopass_area(nopass_area, get_instance_id())


func _on_todo_list_pressed():
    if not todo_widget_activated:
        todo_widget_instance = todo_widget.instantiate()
        get_tree().get_root().add_child(todo_widget_instance)
        todo_widget_activated = true
    else:
        todo_widget_instance.close()
        todo_widget_activated = false

