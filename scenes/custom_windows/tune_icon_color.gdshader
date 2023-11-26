shader_type canvas_item;

uniform vec3 color : source_color;
uniform vec3 bg_color : source_color;
uniform float icon_scale : hint_range(1.0, 2.0, 0.1);

void fragment() {
    vec4 scale_color = vec4(0);

    // AA
//    for (float i = -1.0; i<=1.1; i+=2.0) {
//        for (float j = -1.0; j<=1.1; j+=2.0) {
//            scale_color += texture(TEXTURE, (UV - .08) * icon_scale + vec2(i, j) * TEXTURE_PIXEL_SIZE / icon_scale / 2.) / 4.;
//        }
//    }

    scale_color = texture(TEXTURE, (UV - .08) * icon_scale);
//    vec4 scale_color = texture(TEXTURE, (UV - .15) * icon_scale);
    vec2 st = (UV - vec2(0.5)) * 2.0;
    float n = 3.0;
    float f = pow(abs(st.x), n) + pow(abs(st.y), n);
    f = 1.0 - smoothstep(0.8, 1.0, f);
	COLOR = vec4(color * scale_color.a + bg_color * (1.0 - scale_color.a), f);
}
