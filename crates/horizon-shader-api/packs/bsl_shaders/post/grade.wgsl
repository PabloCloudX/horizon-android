override saturation: f32 = 1.15;
override vignette: bool = true;

fn post(input: PostInput) -> vec4<f32> {
    var c = input.color.rgb;

    // BSL Golden Hour Sunlight Warmth
    let golden = 0.32 * mix(0.2, 1.0, sun_low()) * daylight() * (1.0 - frame.rain * 0.7);
    c *= mix(vec3<f32>(1.0), vec3<f32>(1.08, 1.01, 0.89), golden);

    // BSL Signature Filmic Tonemapping Curve
    c = c * (vec3<f32>(1.0) + c * 0.35) / (c + vec3<f32>(1.0)) * 1.18;

    // BSL Vibrance & Saturation Adjustment
    let lum = luminance(c);
    c = mix(vec3<f32>(lum), c, saturation);

    // Underwater Color Shift
    if frame.eye_in == 1u {
        c *= vec3<f32>(0.28, 0.82, 0.94);
    }

    // BSL Soft Camera Lens Vignette
    if vignette {
        let aspect = frame.resolution.x / frame.resolution.y;
        let d = length((input.uv - 0.5) * vec2<f32>(aspect, 1.0)) / length(vec2<f32>(aspect, 1.0) * 0.5);
        c *= 1.0 - smoothstep(0.60, 1.20, d) * 0.22;
    }

    return vec4<f32>(clamp(c, vec3<f32>(0.0), vec3<f32>(1.0)), input.color.a);
}
