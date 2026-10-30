shader_type canvas_item;
render_mode unshaded;

uniform vec4 some_color : source_color = vec4(1.0);

void fragment() {
	// Output white for every pixel but kee the alpha
	vec4 input_color = texture(TEXTURE, UV);
	COLOR = vec4(some_color.r, some_color.g, some_color.b, input_color.a);
}