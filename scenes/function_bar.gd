extends Control

const area_offset = 1

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
        _instance.tree_exited.connect(on_free)
        _instance.closed.connect(func (): activated = false)

    func close():
        if _instance:
            _instance.close()

    func on_free():
        _instance = null

@onready var path: Path2D = $Path2D

var todo_widget_scene = preload("res://scenes/custom_windows/todo_window.tscn") as PackedScene
var cards_window_scene = preload("res://scenes/custom_windows/cards_window.tscn") as PackedScene
var music_player_widget_scene = preload("res://scenes/music_player_controller.tscn") as PackedScene
var dialog_scene = preload("res://scenes/components/p5_dialog.tscn") as PackedScene

var todo_widget: Widget
var cards_widget: Widget
var music_player_widget: Widget
var dialog_instance: P5Dialog


func _ready():
    todo_widget = Widget.new(todo_widget_scene, get_window())
    cards_widget = Widget.new(cards_window_scene, get_window())
    music_player_widget = Widget.new(music_player_widget_scene, get_window())
    dialog_instance = dialog_scene.instantiate() as Control
    get_window().call_deferred("add_child", dialog_instance)
    # keep_offset=false时不会更新节点的实际位置。为true时才和编辑器中设置锚点的效果相同。
    dialog_instance.set_anchors_preset.call_deferred(PRESET_BOTTOM_LEFT, true)
    dialog_instance.position = Vector2(0, -dialog_instance.size.y - 60)

    var i = 0
    for child in get_children():
        if not child is Control:
            continue
        child.position = path.curve.sample(i, 0) - child.get_rect().size / 2
        i += 1


func update_nopass_area(offset=0):
    # 全屏后新位置要在pet节点ready后获取其新设置的位置
    var nopass_area = PackedVector2Array([
        global_position - Vector2(area_offset, area_offset),
        global_position + Vector2(get_rect().size.x + area_offset + offset, -area_offset),
        global_position + get_rect().size + Vector2(area_offset + offset, area_offset),
        global_position + Vector2(-area_offset, get_rect().size.y + area_offset)
    ])
    EventBus.update_nopass_area(nopass_area, get_instance_id())


func _on_say_something_pressed():
    dialog_instance.show_once("后藤 独", "道可道，非常道。\n名可名，非常名。", 2.0, "res://assets/bochi_haha.png")


func _on_todo_list_pressed():
    todo_widget.activated = not todo_widget.activated


func _on_card_pressed():
    cards_widget.activated = not cards_widget.activated


func _on_music_player_pressed():
    AudioManager.init_music_player()
    music_player_widget.activated = not music_player_widget.activated


func _on_clock_pressed():
    EventBus.emit_clock_pressed()


func _on_count_down_pressed():
    EventBus.emit_countdown_pressed()


func _on_settings_pressed():
    #TODO 配置面板
    pass


func _on_quit_pressed():
    todo_widget.close()
    cards_widget.close()
    music_player_widget.close()
    dialog_instance.queue_free()

    get_tree().quit()
