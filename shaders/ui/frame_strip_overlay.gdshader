shader_type canvas_item;

uniform int frame_count : hint_range(1, 120) = 12;
uniform float fps : hint_range(1.0, 60.0) = 12.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.9;

void fragment() {
	float total_frames = float(max(frame_count, 1));
	float frame_index = floor(mod(TIME * fps, total_frames));
	vec2 animated_uv = UV;
	animated_uv.x = (UV.x + frame_index) / total_frames;

	vec4 frame_color = texture(TEXTURE, animated_uv);
	COLOR = vec4(frame_color.rgb, frame_color.a * alpha_strength);
}
