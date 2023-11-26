class_name TagButton
extends Button


func setup(content: String, tag_color: Color = Color(0.2, 0.5, 0.6), text_color: Color = Color(0.2, 0.6, 0.8)):
    text = "  " + content

    var style_box: StyleBoxFlat = get_theme_stylebox("normal")
    style_box.corner_detail = 1
    # 数值小则尖端会出现平坦区域。数值超过且上下相等时尖端会保持在中间。
    style_box.corner_radius_top_left = int(get_rect().size.y / 2) + 1
    style_box.corner_radius_bottom_left = int(get_rect().size.y / 2) + 1
    style_box.bg_color = tag_color
    style_box.content_margin_bottom = 1
    add_theme_stylebox_override("normal", style_box)
    add_theme_stylebox_override("hover", style_box)
    add_theme_stylebox_override("pressed", style_box)
    add_theme_stylebox_override("focus", style_box)

    add_theme_color_override("font_color", text_color)

