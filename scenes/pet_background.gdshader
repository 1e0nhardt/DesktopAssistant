shader_type canvas_item;

mat2 rotate2D(float theta) {
    return mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)));
}

float star(vec2 st, float flare) {
    float d = length(st);
    float m = 0.05/d;

    float rays = max(0.0, 1.0 - abs(st.x * st.y * 900.0));
    m += rays * flare;

    st *= rotate2D(PI/4.0);
    rays = max(0.0, 1.0 - abs(st.x * st.y * 900.0));
    m += rays * 0.3 * flare;

    // 将星星的光限制在局部，防止后续些微光的累积，导致画面整体变亮。同时也解决了斜向rays无限延伸的问题。
    m *= smoothstep(1.0, 0.2, d);
    return m;
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p+= dot(p, p+45.32);
    return fract(p.x*p.y);
}

vec3 star_layer(vec2 st) {
    vec2 gv = fract(st) - vec2(0.5);
    vec2 id = floor(st);
    vec3 color = vec3(0.0);
    for (float x = -1.0; x<=1.0;x++) {
        for (float y=-1.0;y<=1.0;y++) {
            vec2 offset = vec2(x, y);
            float n = hash21(id + offset); // 0-1
            float size = fract(n * 2315.32);
            float star = star(gv - offset - vec2(n, fract(n*34.21)) + vec2(0.5), smoothstep(0.85, 0.9, size));
            vec3 col = sin(vec3(0.2, 0.3, 0.9) * 123.4 * fract(n*64392.3)) * 0.5 + 0.5;
            col *= vec3(1.0, 0.5, 1.0+size); // 颜色remap。绿色少一点，蓝色随尺寸变多。
            color += star * size * col;
        }
    }
    return color;
}

void fragment() {
    vec2 st = vec2(UV.x, 1.0-UV.y) - vec2(0.5);
    float t = TIME * 0.1;
    st *= 2.0;
    st *= rotate2D(t);
	vec3 color = vec3(0.0);

    float num_layers = 6.0;

    for (float i = 0.0;i<1.0;i+=1.0/num_layers) {
        float depth = fract(i + t);
        float scale = mix(10.0, 0.5, depth);
        // 淡入淡出
        float fade = depth * smoothstep(1.0, 0.95, depth);
        color += star_layer(st * scale + i * 346.5) * fade;
    }

	COLOR = vec4(color, 1.0);
//	COLOR = vec4(vec3(UV.x + UV.y), 1.);
}
