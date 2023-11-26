class_name CardEditorWidget
extends Control

signal updated

@onready var content_editor: TextEdit = %TextEdit
@onready var title_editor: LineEdit = %LineEdit
var card_info: Dictionary


func _ready():
    # 居中显示
    global_position = (get_viewport_rect().size - size) * 0.5
    # Logger.debug("Ready")


func load_card(_card_info):
    card_info = _card_info
    title_editor.text = card_info["title"]
    var tags := []
    for tag in card_info["tags"].split(","):
        tags.append("#" + tag)
    content_editor.text = card_info["content"] + "\n\n" + " ".join(tags)


func close():
    # Logger.debug("Close")
    queue_free()


func _on_save_button_pressed():
    var content = content_editor.text.strip_edges()
    var tags_text = content.split("\n")[-1].strip_edges()
    var tags := []
    for tag in tags_text.split(" "):
        if tag.begins_with("#"):
            tags.append(tag.substr(1))

    if tags.size() == 0:
        tags.append("none")

    Logger.debug("tags", tags)
    content = content.substr(0, content.find("#")).strip_edges()

    if card_info.is_empty():
        Global.card_db.insert(title_editor.text, content, ",".join(tags))
    else:
        Global.card_db.update(card_info["id"], title_editor.text, content, ",".join(tags))

    updated.emit()
    close()


func _on_close_button_pressed():
    close()
