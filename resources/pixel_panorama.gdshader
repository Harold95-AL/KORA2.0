shader_type canvas_item;

// Sharpen luminance on the source pixel grid while retaining the painted palette.
varying vec4 tint;
void vertex() {
    tint = COLOR;
}
void fragment() {
    vec2 p = TEXTURE_PIXEL_SIZE;
    vec4 base = texture(TEXTURE, UV);
    vec3 around = (texture(TEXTURE, UV + vec2(p.x, 0.0)).rgb
                 + texture(TEXTURE, UV - vec2(p.x, 0.0)).rgb
                 + texture(TEXTURE, UV + vec2(0.0, p.y)).rgb
                 + texture(TEXTURE, UV - vec2(0.0, p.y)).rgb) * 0.25;
    vec3 detail = clamp(base.rgb - around, vec3(-0.055), vec3(0.055));
    COLOR = vec4(clamp(base.rgb + detail * 0.85, 0.0, 1.0), base.a) * tint;
}
