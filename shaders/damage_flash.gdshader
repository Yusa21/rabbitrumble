shader_type canvas_item;

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color : source_color = vec3(1.0, 0.0, 0.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 final_color = mix(tex_color.rgb, flash_color, flash_intensity);
    COLOR = vec4(final_color, tex_color.a);
}