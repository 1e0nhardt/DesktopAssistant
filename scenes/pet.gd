extends Node2D

@onready var draggable_component = $DraggableComponent
@onready var function_bar = %FunctionBar
@onready var sprite = $Sprite
@onready var timer: Timer = %Timer
@onready var time_label: Label = %TimeLabel

var mouse_in_sprite := false
var current_time_left := 0
var timer_count := 0


func _ready():
    draggable_component.drag_ended.connect(on_drag_ended)
    # 初始位置设为右下角
    global_position = get_viewport_rect().size - draggable_component.get_sprite_size() - Vector2(0, 60)
    Logger.info("Viewport size", get_viewport_rect())
    # Logger.debug("Sprite size", get_sprite_size())
    # Logger.debug("init position", get_parent().global_position)
    draggable_component.update_nopass_area()
    function_bar.update_nopass_area()
    Logger.debug("Pet position", global_position)

    Global.test()
    EventBus.countdown_pressed.connect(on_countdown_pressed)
    EventBus.clock_pressed.connect(on_clock_pressed)


func _process(_delta):
    function_bar.visible = get_active_rect().has_point(get_global_mouse_position())


func get_active_rect():
    var target_rect = Rect2()
    target_rect.position = function_bar.global_position
    target_rect.size = function_bar.size
    return target_rect


func clear_timer():
    time_label.hide()
    timer.stop()

    if timer.timeout.is_connected(update_countdown_time):
        timer.timeout.disconnect(update_countdown_time)

    if timer.timeout.is_connected(update_timer_time):
        timer.timeout.disconnect(update_timer_time)


func update_countdown_time():
    current_time_left -= 1
    time_label.text = "%02d:%02d" % [current_time_left / 60, current_time_left % 60]
    if current_time_left <= 0:
        clear_timer()
        AudioManager.play_sound(0)


func update_timer_time():
    timer_count += 1
    time_label.text = "%02d:%02d" % [timer_count / 60, timer_count % 60]


func on_clock_pressed():
    if timer.is_stopped():
        timer.start()
        timer.timeout.connect(update_timer_time)
        timer_count = -1
        update_timer_time()
        time_label.show()
    else:
        clear_timer()


func on_countdown_pressed():
    if timer.is_stopped():
        timer.start()
        timer.timeout.connect(update_countdown_time)
        current_time_left = int(Global.count_down_amount * 60) + 1
        update_countdown_time()
        time_label.show()
    else:
        clear_timer()


func on_drag_ended():
    function_bar.update_nopass_area()
