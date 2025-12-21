shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0,1) = 0.2;

uniform vec4 heat_color : source_color = vec4(1.0, 0.5, 0.0, 0.1);


void fragment() {
	vec2 offset = vec2(
		sin(TIME * 1.5 + SCREEN_UV.y * 10.0),
		cos(TIME * 1.0 + SCREEN_UV.x * 5.0)
	) * strength;
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
	vec4 boosted = screen + heat_color * 2.0;
	COLOR = mix(screen,boosted,heat_color.a);
}