extends Control

@export var box_color: Color:
    set(value):
        box_color = value
        set_box_color(value)
@export var border_color: Color:
    set(value):
        border_color = value
        set_border_color(value)

@onready var dialog_node = $DialogNode
@onready var dialog_box = $DialogNode/DialogBox
@onready var dialog_box_border = $DialogNode/DialogBox/DialogBoxBorder
@onready var name_box = $DialogNode/NameBox
@onready var name_box_content = $DialogNode/NameBox/NameBoxContent
@onready var mark_node = $DialogNode/MarkNode
@onready var mark_box = $DialogNode/MarkNode/MarkBox
@onready var mark_box_content = $DialogNode/MarkNode/MarkBox/MarkBoxContent

@onready var name_label: Label = $NameLabel
@onready var text_label: Label = $TextLabel
@onready var contrast_label: Label = %ContrastLabel

var t := 0.0
var mark_node_origin: Vector2
var mark_node_origin_init: Vector2
var change_target_flag := false
var prev_lines: int
var dialog_font_size: int

var dialog_box_animation_vertices: Array = [2,3,4,11,12,13,14,5,10]
var dialog_box_border_animation_vertices: Array = [
    1,2,3,8,9,10,
    22,21,20,15,14,13,
    4,19,7,16
]
var name_box_animation_vertices: Array = [1,2,3,4,5,6]
var name_box_content_animation_vertices: Array = [2,3,4,5,6,7]
var dialog_box_right_vertices: Array = [6,7,8,9]
var dialog_box_border_right_vertices: Array = [5,6,17,18]

var box_polygon: PackedVector2Array
var box_border_polygon: PackedVector2Array
var name_polygon: PackedVector2Array
var name_content_polygon: PackedVector2Array


func _ready():
    mark_node_origin = Vector2(520, 60)
    mark_node_origin_init = Vector2(520, 60)
    box_polygon = dialog_box.polygon.duplicate()
    box_border_polygon = dialog_box_border.polygon.duplicate()
    name_polygon = name_box.polygon.duplicate()
    name_content_polygon = name_box_content.polygon.duplicate()
    dialog_font_size = text_label.get_theme_font_size("font_size")

    set_box_color(box_color)
    set_border_color(border_color)
    set_character_name("喜多川 佑介")
    set_dialog("心之怪盗团一二三四五六七八九十一二三\ntake your heart!")
    get_tree().create_timer(1.5).timeout.connect(func (): set_dialog("大学之道，在明明德，在亲民，在止于至善。欲明明德于天下者，必治其国。"))
    get_tree().create_timer(3.0).timeout.connect(func (): set_dialog("大学之道，在明明德，在亲民，在止于至善。\n欲明明德于天下者，必治其国。"))
    get_tree().create_timer(4.5).timeout.connect(func (): set_dialog("大学之道\n欲明明德于天下者，必治其国。"))
    get_tree().create_timer(6).timeout.connect(func (): set_dialog("大学之道，在明明德，在亲民，在止于至善。"))


func _process(delta):
    t += delta
    for v in dialog_box_border_animation_vertices:
        dialog_box_border.polygon[v] = animate_point(box_border_polygon[v], 6, v)
    for v in dialog_box_animation_vertices:
        dialog_box.polygon[v] = animate_point(box_polygon[v], 6, v)
    for v in name_box_animation_vertices:
        name_box.polygon[v] = animate_point(name_polygon[v], 6, v)
    for v in name_box_content_animation_vertices:
        name_box_content.polygon[v] = animate_point(name_content_polygon[v], 6, v)
    animate_mark(delta)


func animate_mark(delta: float):
    var curve := triangle_curve(t)
    if curve - triangle_curve(t - delta) < 0 and triangle_curve(t + delta) - curve > 0:
        change_target_flag = not change_target_flag
    var mark_target = Vector2( 8, 2) if change_target_flag else Vector2(4, -6)

    mark_node.position = mark_node_origin + curve * mark_target
    mark_node.scale =  Vector2(1 + curve * 0.2, 1 + curve * 0.2)


func animate_point(point: Vector2, r: float, index: int):
    var curve := triangle_curve(t + index / 2.0)
    return point + curve * Vector2(r / 2.0, ((index % 2) - 0.5) * r)


func triangle_curve(x: float, T=1.0) -> float:
    # 周期为1的三角波
    return abs((fmod(x, T)) * 2.0 * T - T)


func set_box_color(c: Color):
    if not is_node_ready():
        return

    dialog_box.color = c
    name_box.color = c
    mark_box.color = c


func set_border_color(c: Color):
    if not is_node_ready():
        return

    dialog_box_border.color = c
    name_box_content.color = c
    mark_box_content.color = c


func set_character_name(n: String):
    name_label.text = n
    contrast_label.text = n[1]


func set_dialog(n: String):
    text_label.text = n

    var max_line_length = 0
    var lines = n.split("\n")
    for line in lines:
        if line.length() > 15 and line.length() > max_line_length:
            max_line_length = line.length()

    Logger.debug("Lines", lines)
    # 只考虑台词有1行或2行的情况
    if lines.size() == 1 and prev_lines != 1:
        box_polygon[6] += Vector2(0, -dialog_font_size)
        box_border_polygon[5] += Vector2(0, -dialog_font_size)
        box_border_polygon[18] += Vector2(0, -dialog_font_size)
        prev_lines = 1
    elif prev_lines == 1:
        box_polygon[6] -= Vector2(0, -dialog_font_size)
        box_border_polygon[5] -= Vector2(0, -dialog_font_size)
        box_border_polygon[18] -= Vector2(0, -dialog_font_size)
        prev_lines = lines.size()

    var text_label_expand_width = 0
    if max_line_length > 15:
        text_label_expand_width = dialog_font_size * (max_line_length - 15)

        for v in dialog_box_right_vertices:
            dialog_box.polygon[v] = box_polygon[v] + Vector2(text_label_expand_width, 0)
        for v in dialog_box_border_right_vertices:
            dialog_box_border.polygon[v] = box_border_polygon[v] + Vector2(text_label_expand_width, 0)

        Logger.debug("Dialog Size", text_label_expand_width)

    mark_node_origin = mark_node_origin_init + Vector2(text_label_expand_width, 0)
