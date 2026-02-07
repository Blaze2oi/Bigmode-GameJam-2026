shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float offset : hint_range(0.0, 5.0) = 0.0;

void fragment() {
    // Offset the red and blue channels in opposite directions
    vec4 red_channel = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x * offset, 0.0));
    vec4 green_channel = texture(screen_texture, SCREEN_UV);
    vec4 blue_channel = texture(screen_texture, SCREEN_UV - vec2(SCREEN_PIXEL_SIZE.x * offset, 0.0));
    
    COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, 1.0);
}