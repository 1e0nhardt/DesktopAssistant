shader_type canvas_item;

uniform vec3 color : source_color;

void fragment() {
    COLOR = vec4(color, COLOR.a);
}
