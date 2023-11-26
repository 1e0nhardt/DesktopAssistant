class_name Card
extends TextureRect

@onready var title_label: Label = %TitleLabel
@onready var content_label: TextEdit = %TextEdit
@onready var tag_container: HFlowContainer = %TagContainer

var tag_button_scene = preload("res://scenes/components/tag_button.tscn")
var cards_window_scene = preload("res://scenes/custom_windows/card_edit_window.tscn") as PackedScene
var card_info: Dictionary


func _ready():
    pass
    # setup({
    #     "title": "hello",
    #     "content": "content",
    #     "tags": "test, dev, nihao"
    # })


func setup(_card_info: Dictionary):
    card_info = _card_info
    title_label.text = card_info["title"]
    content_label.text = card_info["content"]

    for child in tag_container.get_children():
        child.queue_free()

    for tag in card_info["tags"].split(","):
        var tag_button = tag_button_scene.instantiate()
        tag_container.add_child(tag_button)
        tag_button.setup(tag) # TODO random color


func _on_gui_input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        var cards_window_instance = cards_window_scene.instantiate()
        get_window().add_child(cards_window_instance)
        cards_window_instance.load_card(card_info)
        cards_window_instance.updated.connect(on_card_updated)


func on_card_updated():
    var new_card_info = Global.card_db.query_by_id(int(card_info["id"]))
    setup(new_card_info)
