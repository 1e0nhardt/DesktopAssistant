extends Control

signal closed

@onready var search_text: LineEdit = %TagFilter
@onready var card_container: HFlowContainer = %GridContainer
@onready var page_number_edit: LineEdit = %PageNumber

var card_scene = preload("res://scenes/components/card.tscn")

enum MODE { ALL, TAG }

var mode := MODE.ALL
var current_tags := ""
var prev_tags := ""
var page_size := 8
var page_number := 1:
    set(value):
        page_number = value
        page_number_edit.text = str(value) + "/" + str(page_count)
        match mode:
            MODE.ALL: update_cards()
            MODE.TAG: update_cards_by_tags(current_tags)

var offset: int:
    get:
        return (page_number - 1) * page_size

var page_count_cache: int = -1
var page_count: int:
    get:
        if prev_tags == current_tags:
            return page_count_cache
        match mode:
            MODE.TAG:
                page_count_cache = ceili(Global.card_db.query_tag_count(current_tags) / float(page_size))
            _:
                page_count_cache = ceili(Global.card_db.query_all_count() / float(page_size))
        return page_count_cache


func _ready():
    # 居中显示
    global_position = (get_viewport_rect().size - size) * 0.5
    Logger.debug("data", Global.card_db.query_all(page_size, offset))
    page_count_cache = ceili(Global.card_db.query_all_count() / float(page_size))
    page_number_edit.text = "1/" + str(page_count_cache)
    update_cards()


func update_cards():
    for child in card_container.get_children():
        child.queue_free()

    for record in Global.card_db.query_all(page_size, offset):
        var card_instance = card_scene.instantiate()
        card_container.add_child(card_instance)
        card_instance.setup(record)


func update_cards_by_tags(new_text):
    for child in card_container.get_children():
        child.queue_free()

    for record in Global.card_db.query_by_tag(new_text, page_size, offset):
        var card_instance = card_scene.instantiate()
        card_container.add_child(card_instance)
        Logger.debug("Tag record", record)
        card_instance.setup(record)


func close():
    queue_free()


func _on_close_button_pressed():
    closed.emit()


func _on_first_page_pressed():
    page_number = 1


func _on_prev_page_pressed():
    if page_number == 1:
        return

    page_number -= 1


func _on_next_page_pressed():
    if page_number < page_count:
        page_number += 1


func _on_last_page_pressed():
    page_number = page_count


func _on_page_number_text_submitted(new_text):
    if not new_text is int:
        Logger.warn("PageNumber should be integer! But get %s" % new_text)
        return

    page_number = int(new_text)


func _on_tag_filter_text_submitted(new_text):
    if new_text == "":
        mode = MODE.ALL
    else:
        mode = MODE.TAG

    current_tags = new_text
    page_number = 1
