shader_type canvas_item;

uniform vec3 background_color : source_color;

void fragment() {
    vec3 color = background_color;
	COLOR = vec4(color, 1.);
}
