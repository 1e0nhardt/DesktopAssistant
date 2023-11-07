extends Node2D

const area_offset := 1 # 没有offset，边缘会抖动。

signal drag_started(event_position: Vector2)
signal drag_ended

var draggable_sprite

var drag_offset: Vector2
var dragging := false

var parent_visible_changed: bool = false
var parent_visible_pre: bool = false
var parent_visible: bool:
    get:
        var v = get_parent().visible
        if v != parent_visible_pre:
            parent_visible_changed = true
            parent_visible_pre = v
        else:
            parent_visible_changed = false
        return v

func _ready():
    # 父节点需要挂一个Sprite节点，这个节点需要有get_rect()方法和global_position属性。且锚点需要在左上角。
    draggable_sprite = get_parent().get_node("Sprite")


func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_in_rect():
        # Logger.debug("sprite rect", draggable_sprite.get_rect()) # get_rect()返回的是局部坐标系中的坐标。
        # Logger.debug("sprite position", draggable_sprite.global_position) # global_position 是锚点位置
        # Logger.debug("parent position", get_parent().global_position) # global_position 是锚点位置
        if event.is_pressed():
            on_drag_started(event.position)
            drag_started.emit(event.position)
        else:
            on_drag_ended()
            drag_ended.emit()


func _process(_delta):
    if not parent_visible and parent_visible_changed: # 鼠标穿透区域也要改变
        EventBus.update_nopass_area([], id)
    elif parent_visible_changed:
        update_nopass_area()

    if dragging:
        var new_pos = get_global_mouse_position() - drag_offset
        get_parent().global_position = new_pos


func mouse_in_rect():
    return Rect2(draggable_sprite.global_position, get_sprite_size()).has_point(get_global_mouse_position())


func get_sprite_size():
    if draggable_sprite is Sprite2D:
        return draggable_sprite.get_rect().size * draggable_sprite.scale
    else:
        Logger.warn("sprite size is zero")
        get_tree().quit()

var id = EventBus.gen_id()

func update_nopass_area():
    var nopass_area = PackedVector2Array([
        draggable_sprite.global_position - Vector2(area_offset, area_offset),
        draggable_sprite.global_position + Vector2(get_sprite_size().x + area_offset, -area_offset),
        draggable_sprite.global_position + get_sprite_size() + Vector2(area_offset, area_offset),
        draggable_sprite.global_position + Vector2(-area_offset, get_sprite_size().y + area_offset)
    ])
    EventBus.update_nopass_area(nopass_area, id)
    # EventBus.update_nopass_area(nopass_area, get_instance_id())


func on_drag_started(event_position: Vector2):
    dragging = true
    drag_offset = event_position - get_parent().global_position
    # 拖动时会出现白边，改为拖动时nopass_area为整个屏幕，停止拖动时再改回来，就可以避免。
    # DisplayServer.window_set_mouse_passthrough([])
    EventBus.set_fullscreen_nopass_area()
    # 同时拖动多个时会闪白屏, 可能是DisplayServer.window_set_mouse_passthrough([])连续调用的导致的


func on_drag_ended():
    dragging = false
    update_nopass_area()
