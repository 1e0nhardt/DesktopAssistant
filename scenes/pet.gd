extends Node2D

@onready var draggable_component = $DraggableComponent

func _ready():
    # 初始位置设为右下角
    global_position = get_viewport_rect().size - draggable_component.get_sprite_size() - Vector2(0, 60)
    Logger.info("Viewport size", get_viewport_rect())
    # Logger.debug("Sprite size", get_sprite_size())
    # Logger.debug("init position", get_parent().global_position)
    draggable_component.update_nopass_area()
    Logger.debug("Pet position", global_position)