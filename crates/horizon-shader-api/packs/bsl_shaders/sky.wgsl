override sun_warmth: f32 = 0.7;

fn sky(input: SkyInput) -> vec4<f32> {
    let d = input.direction;
    let day = daylight() * (1.0 - frame.rain * 0.8);
    let toward_sun = max(dot(d, frame.sun_direction), 0.0);
    let horizon_factor = 1.0 - smoothstep(0.0, 0.42, abs(d.y));

    // BSL Rayleigh scattering approximation
    let zenith_day = vec3<f32>(0.14, 0.36, 0.75);
    let horizon_day = vec3<f32>(0.88, 0.82, 0.74);
    let day_sky = mix(zenith_day, horizon_day, horizon_factor);

    // BSL Sunset / Sunrise Twilight Palette
    let sunset_horizon = vec3<f32>(1.0, 0.42, 0.12);
    let sunset_mid = vec3<f32>(0.74, 0.32, 0.54);
    let sunset_zenith = vec3<f32>(0.09, 0.13, 0.30);
    let sunset_sky = mix(sunset_zenith, mix(sunset_mid, sunset_horizon, horizon_factor), horizon_factor);

    // BSL Sun Corona / Atmospheric glow
    let sun_disk = pow(toward_sun, 10.0) * 0.85 + pow(toward_sun, 2.5) * horizon_factor * 0.4;
    let sun_corona = vec3<f32>(1.0, 0.65, 0.28) * sun_disk * sun_warmth;

    // Night atmosphere & Lunar glow
    let night = (1.0 - day) * (1.0 - frame.rain);
    let toward_moon = max(dot(d, frame.moon_direction), 0.0);
    let moon_halo = pow(toward_moon, 14.0) * 0.35 + pow(toward_moon, 3.0) * 0.08;
    let night_sky = vec3<f32>(0.03, 0.06, 0.14) + vec3<f32>(0.12, 0.18, 0.32) * moon_halo;

    // Blend day, sunset, and night
    let sunset_weight = sun_low() * day;
    var final_sky = mix(day_sky, sunset_sky, sunset_weight * 0.9);
    final_sky = mix(night_sky, final_sky, day);
    final_sky += sun_corona * day;

    // Preserve cloud & fog alpha balance with vanilla backdrop
    let blended = mix(input.color.rgb, final_sky, 0.75);
    return vec4<f32>(blended, input.color.a);
}
