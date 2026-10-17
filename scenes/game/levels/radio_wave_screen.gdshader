shader_type spatial;
render_mode unshaded, cull_back, depth_draw_never;

uniform int display_mode = 0; // 0 = tuning, 1 = calibration
uniform vec4 background_color : source_color = vec4(0.003, 0.012, 0.012, 1.0);
uniform vec4 primary_color : source_color = vec4(0.20, 1.0, 0.78, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.72, 0.35, 1.0, 1.0);
uniform float frequency = 15.0;
uniform float amplitude = 0.20;
uniform float phase_offset = 0.0;
uniform float frequency_scale = 1.0;
uniform float noise_strength = 0.012;
uniform float glow_strength = 1.8;
uniform float grid_strength = 0.13;
uniform float scanline_strength = 0.045;
uniform float animation_speed = 0.8;
uniform float trace_width = 0.012;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float line_mask(float distance_to_line, float width) {
    return 1.0 - smoothstep(width, width * 2.8, distance_to_line);
}

void fragment() {
    // UV.x is the horizontal time axis; UV.y is the vertical voltage axis.
    vec2 uv = UV;
    float t = TIME * animation_speed;

    // Fine static-like interference. Keep it subtle so the trace remains readable.
    float noise = (hash(floor(uv * vec2(260.0, 130.0) + t * 13.0)) - 0.5) * noise_strength;
    float jitter = sin(uv.x * 93.0 + t * 7.0) * noise_strength * 0.35;

    float center_y = 0.5;
    float wave_a = center_y + sin((uv.x * frequency - t) * 6.2831853) * amplitude
        + sin(uv.x * 37.0 + t * 2.1) * noise_strength * 0.45 + jitter;

    float dist_a = abs(uv.y - wave_a);
    float trace_a = line_mask(dist_a, trace_width);
    float halo_a = line_mask(dist_a, trace_width * 5.5) * 0.22;

    float wave_b = center_y + sin((uv.x * frequency * frequency_scale - t + phase_offset) * 6.2831853)
        * amplitude + sin(uv.x * 31.0 + t * 1.7) * noise_strength * 0.3 - jitter;
    float dist_b = abs(uv.y - wave_b);
    float trace_b = line_mask(dist_b, trace_width);
    float halo_b = line_mask(dist_b, trace_width * 5.5) * 0.22;

    // Screen 1: one trace. Screen 2: reference + adjustable trace.
    if (display_mode == 0) {
        trace_b = 0.0;
        halo_b = 0.0;
    }

    vec3 color = background_color.rgb;

    // Oscilloscope grid with a brighter central crosshair.
    vec2 grid_uv = uv * vec2(12.0, 8.0);
    vec2 grid_dist = abs(fract(grid_uv) - 0.5);
    float grid_line = max(
        1.0 - smoothstep(0.475, 0.495, grid_dist.x),
        1.0 - smoothstep(0.475, 0.495, grid_dist.y)
    );
    color += vec3(0.025, 0.12, 0.105) * grid_line * grid_strength;
    float center_line = max(
        1.0 - smoothstep(0.0, 0.006, abs(uv.x - 0.5)),
        1.0 - smoothstep(0.0, 0.006, abs(uv.y - 0.5))
    );
    color += vec3(0.025, 0.16, 0.13) * center_line * 0.25;

    color += primary_color.rgb * (trace_a * glow_strength + halo_a * glow_strength * 0.65);
    color += secondary_color.rgb * (trace_b * glow_strength + halo_b * glow_strength * 0.65);

    // CRT phosphor scanlines and low-level analog noise.
    float scan = sin(uv.y * 900.0) * scanline_strength;
    color *= 1.0 - scan;
    color += vec3(noise * 0.35);

    // Slight vignette keeps the corners darker, like an old CRT.
    float vignette = 1.0 - smoothstep(0.25, 0.82, distance(uv, vec2(0.5)));
    color *= 0.72 + vignette * 0.28;

    ALBEDO = color;
    EMISSION = color * 0.32;
    ROUGHNESS = 1.0;
}
