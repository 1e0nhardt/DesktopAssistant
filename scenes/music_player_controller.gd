extends PanelContainer

signal closed

@onready var volume_slider: HSlider = %VolumeSlider
@onready var item_list: ItemList = %ItemList
@onready var draggable_component = $DraggableComponent
@onready var name_label = %Label
@onready var play_button: TextureButton = %PlayButton

var raw_size: Vector2
var hidding := false
var play_flag := false
var play_icon = preload("res://assets/icons/play.png")
var stop_icon = preload("res://assets/icons/stop.png")


func _ready():
    # 居中显示
    global_position = (get_viewport_rect().size - size) * 0.5
    raw_size = size

    AudioManager.music_player.change_song.connect(on_song_changed)
    AudioManager.mucis_stream_player.finished.connect(on_song_finished)
    AudioManager.music_player.current_index = 0

    for song_name in AudioManager.music_player.song_names:
        item_list.add_item(song_name)


func _process(_delta):
    if draggable_component.dragging:
        return

    # 在边缘，且鼠标不在rect内，隐藏。
    # 隐藏时，鼠标在一定范围内，解除隐藏
    if global_position.y < 5 and not get_rect().has_point(get_global_mouse_position()) and not hidding:
        hidding = true
        global_position = Vector2(global_position.x, -62)
        draggable_component.update_nopass_area()
    else:
        var detect_rect = Rect2()
        detect_rect.position = Vector2(global_position.x, 0)
        detect_rect.size = Vector2(size.x, 10)
        if detect_rect.has_point(get_global_mouse_position()):
            hidding = false
            global_position = Vector2(global_position.x, 0)
            draggable_component.update_nopass_area()


func close():
    AudioManager.music_player.pause()
    queue_free()


func on_song_changed(song_name: String):
    name_label.text = song_name


func on_song_finished():
    # Logger.debug("Finished")
    AudioManager.music_player.next()


func _on_prev_button_pressed():
    AudioManager.music_player.prev()


func _on_play_button_pressed():
    AudioManager.music_player.pause()
    play_flag = not play_flag
    play_button.texture_normal = play_icon if play_flag else stop_icon


func _on_next_button_pressed():
    #TODO 设置播放模式选项
    AudioManager.music_player.next()


func _on_volume_button_pressed():
    volume_slider.visible = not volume_slider.visible
    if not volume_slider.visible:
        size = raw_size
    else:
        size = raw_size + Vector2(0, volume_slider.size.y)
    draggable_component.dragging = false


func _on_list_button_pressed():
    item_list.visible = not item_list.visible
    # 通过visible撑开的size更新时机不确定，这里必须直接手工计算出来
    if not item_list.visible:
        size = raw_size
    else:
        size = raw_size + Vector2(0, item_list.size.y)
    draggable_component.dragging = false


func _on_quit_button_pressed():
    closed.emit()


func _on_item_list_item_activated(index):
    AudioManager.music_player.current_index = index


func _on_volume_slider_value_changed(value):
    AudioManager.music_player.set_volume(value)
