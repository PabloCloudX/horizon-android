override bloom: f32 = 0.45;

fn bright_pass(uv: vec2<f32>) -> vec3<f32> {
    let c = textureSampleLevel(previous, linear_sampler, uv, 0.0).rgb;
    let is_sky = depth_at(uv) == 0.0;
    let lum = luminance(c);
    // Extract highlights: torches, glowstones, lava, sun, and bright sky
    let threshold = select(0.72, 0.92, is_sky);
    let factor = smoothstep(threshold, 1.25, lum);
    return c * factor;
}

fn post(input: PostInput) -> vec4<f32> {
    if bloom <= 0.0 {
        return input.color;
    }
    let step = (frame.resolution.y / 720.0) / frame.resolution;
    var sum = vec3<f32>(0.0);
    // 12-tap dual-ring Poisson-like sampling for smooth, wide BSL bloom
    for (var i = 0; i < 12; i++) {
        let angle = f32(i) * 0.5235988;
        let radius = select(3.5, 8.5, (i & 1) == 1);
        let offset = vec2<f32>(cos(angle), sin(angle)) * radius * step;
        sum += bright_pass(input.uv + offset);
    }
    let bloom_radiance = sum * (bloom * 0.125);
    return vec4<f32>(input.color.rgb + bloom_radiance, input.color.a);
}
