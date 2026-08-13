shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform bool use_clip = false;
uniform vec2 clip_a = vec2(0.0);
uniform vec2 clip_b = vec2(1.0, 0.0);
uniform vec2 clip_c = vec2(1.0);
uniform vec2 clip_d = vec2(0.0, 1.0);
uniform float saturation = 1.0;
uniform float contrast = 1.0;
uniform float blur_amount = 0.0;

varying vec4 layer_modulate;


void vertex() {
	layer_modulate = COLOR;
}


float edge_side(vec2 a, vec2 b, vec2 p) {
	return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
}


void fragment() {
	vec4 effect_color = texture(TEXTURE, UV);
	if (blur_amount > 0.001) {
		vec2 delta = TEXTURE_PIXEL_SIZE * blur_amount;
		effect_color = (
			texture(TEXTURE, UV) * 4.0
			+ texture(TEXTURE, UV + vec2(delta.x, 0.0))
			+ texture(TEXTURE, UV - vec2(delta.x, 0.0))
			+ texture(TEXTURE, UV + vec2(0.0, delta.y))
			+ texture(TEXTURE, UV - vec2(0.0, delta.y))
		) / 8.0;
	}
	float luminance = dot(effect_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 adjusted = mix(vec3(luminance), effect_color.rgb, saturation);
	adjusted = (adjusted - vec3(0.5)) * contrast + vec3(0.5);
	float clip_alpha = 1.0;
	if (use_clip) {
		float side_a = edge_side(clip_a, clip_b, UV);
		float side_b = edge_side(clip_b, clip_c, UV);
		float side_c = edge_side(clip_c, clip_d, UV);
		float side_d = edge_side(clip_d, clip_a, UV);
		bool positive = side_a >= 0.0 && side_b >= 0.0 && side_c >= 0.0 && side_d >= 0.0;
		bool negative = side_a <= 0.0 && side_b <= 0.0 && side_c <= 0.0 && side_d <= 0.0;
		clip_alpha = (positive || negative) ? 1.0 : 0.0;
	}
	vec3 backdrop = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	vec3 screened = vec3(1.0) - (vec3(1.0) - backdrop) * (vec3(1.0) - adjusted);
	COLOR = vec4(screened, effect_color.a * clip_alpha) * layer_modulate;
}
