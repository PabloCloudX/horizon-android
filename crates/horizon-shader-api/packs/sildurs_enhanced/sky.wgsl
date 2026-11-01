override sun_warmth: f32 = 0.6;

fn sky(input: SkyInput) -> vec4<f32> {
    let d = input.direction;
    let day = daylight() * (1.0 - frame.rain * 0.75);
    let toward_sun = max(dot(d, frame.sun_direction), 0.0);
    let near_horizon = 1.0 - smoothstep(0.0, 0.35, abs(d.y));

    // Sildur's sun halo & atmospheric scattering
    let sun_disk = pow(toward_sun, 8.0) * 0.7 + pow(toward_sun, 2.0) * near_horizon * 0.3;
    let warm_color = vec3<f32>(1.0, 0.58, 0.22) * sun_disk * sun_low() * day * sun_warmth;

    // Deep azure zenith transition
    let zenith_boost = smoothstep(0.05, 0.95, max(d.y, 0.0)) * day * 0.15;
    let base_sky = input.color.rgb * (1.0 + zenith_boost * vec3<f32>(-0.2, 0.05, 0.3));

    // Night ambient atmosphere
    let night = (1.0 - day) * (1.0 - frame.rain);
    let toward_moon = max(dot(d, frame.moon_direction), 0.0);
    let moon_halo = pow(toward_moon, 12.0) * 0.25 * night;
    let night_sky = base_sky + vec3<f32>(0.05, 0.08, 0.16) * moon_halo;

    return vec4<f32>(night_sky + warm_color, input.color.a);
}
