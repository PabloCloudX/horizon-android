override saturation: f32 = 1.15;
override vignette: bool = true;

fn post(input: PostInput) -> vec4<f32> {
    var c = input.color.rgb;

    // Sildur's warm sunlight tonemap & golden hour balance
    let golden = 0.35 * mix(0.2, 1.0, sun_low()) * daylight() * (1.0 - frame.rain * 0.7);
    c *= mix(vec3<f32>(1.0), vec3<f32>(1.08, 1.0, 0.88), golden);

    // Sildur's soft shoulder tonemapping
    c = c / (1.0 + 0.22 * c) * 1.22;

    // Saturation boost
    let lum = luminance(c);
    c = mix(vec3<f32>(lum), c, saturation);

    // Underwater color absorption
    if frame.eye_in == 1u {
        c *= vec3<f32>(0.35, 0.85, 0.95);
    }

    // Soft camera vignette
    if vignette {
        let aspect = frame.resolution.x / frame.resolution.y;
        let d = length((input.uv - 0.5) * vec2<f32>(aspect, 1.0)) / length(vec2<f32>(aspect, 1.0) * 0.5);
        c *= 1.0 - smoothstep(0.55, 1.15, d) * 0.25;
    }

    return vec4<f32>(clamp(c, vec3<f32>(0.0), vec3<f32>(1.0)), input.color.a);
}
