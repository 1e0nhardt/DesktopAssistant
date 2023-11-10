extends VBoxContainer

const area_offset = 1
const hide_offset = 10

class Widget:
    var _scene: PackedScene
    var _parent: Node
    var _instance: Node
    var activated := false:
        set(value):
                activated = value
                if activated:
                    open()
                else:
                    close()

    func _init(scene: PackedScene, parent_node: Node):
        _scene = scene
        _parent = parent_node

    func open():
        _instance = _scene.instantiate()
        _parent.add_child(_instance)

    func close():
        if activated:
            _instance.close()

var todo_widget_scene = preload("res://scenes/custom_windows/todo_window.tscn") as PackedScene
var music_player_widget_scene = preload("res://scenes/music_player_controller.tscn") as PackedScene

var todo_widget: Widget
var music_player_widget: Widget

var hidding = false
var pre_position: Vector2


func _ready():
    todo_widget = Widget.new(todo_widget_scene, get_window())
    music_player_widget = Widget.new(music_player_widget_scene, get_window())


func update_nopass_area(offset=0):
    # 全屏后新位置要在pet节点ready后获取其新设置的位置
    var nopass_area = PackedVector2Array([
        global_position - Vector2(area_offset, area_offset),
        global_position + Vector2(get_rect().size.x + area_offset + offset, -area_offset),
        global_position + get_rect().size + Vector2(area_offset + offset, area_offset),
        global_position + Vector2(-area_offset, get_rect().size.y + area_offset)
    ])
    EventBus.update_nopass_area(nopass_area, get_instance_id())


func _on_todo_list_pressed():
    todo_widget.activated = not todo_widget.activated


func _on_music_player_pressed():
    AudioManager.init_music_player()
    music_player_widget.activated = not music_player_widget.activated


func _on_hide_pressed():
    # 从边缘被拖出来后，就当它不隐藏了
    if hidding and get_viewport_rect().size.x - global_position.x > size.x + hide_offset + 100:
        hidding = false

    if not hidding:
        pre_position = get_parent().global_position
        get_parent().global_position = Vector2(get_viewport_rect().size.x - hide_offset, global_position.y)
        update_nopass_area(hide_offset + 5)
        get_parent().draggable_component.update_nopass_area()
    else:
        get_parent().global_position = pre_position
        update_nopass_area()
        get_parent().draggable_component.update_nopass_area()

    hidding = not hidding


func _on_quit_pressed():
    todo_widget.close()
    music_player_widget.close()

    get_tree().quit()
