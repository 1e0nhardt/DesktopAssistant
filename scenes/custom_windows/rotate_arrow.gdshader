shader_type canvas_item;

uniform vec3 color : source_color;
uniform float rotation;

void fragment() {
    float theta = rotation / 180. * PI;
    mat2 rot2d = mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)));
    vec2 st = UV - vec2(.5, .5);
    st = rot2d * st + vec2(.5, .5);
    vec4 c = texture(TEXTURE, st);
    c.rgb = color;
	COLOR = vec4(c);
}
