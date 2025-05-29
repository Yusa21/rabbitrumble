shader_type canvas_item;

uniform float wave_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 heal_color : source_color = vec3(0.0, 1.0, 0.0);
uniform float wave_width : hint_range(0.1, 1.0) = 0.3;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Create a wave that moves from left to right
    float wave_pos = wave_progress;
    float dist_from_wave = abs(UV.x - wave_pos);

    // Create a smooth wave effect
    float wave_intensity = 1.0 - smoothstep(0.0, wave_width, dist_from_wave);
    wave_intensity *= wave_progress; // Fade in as it progresses

    vec3 final_color = mix(tex_color.rgb, heal_color, wave_intensity * 0.8);
    COLOR = vec4(final_color, tex_color.a);
}