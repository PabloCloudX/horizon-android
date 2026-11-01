fn luminance(c: vec3<f32>) -> f32 {
    return dot(c, vec3<f32>(0.2126, 0.7152, 0.0722));
}

// 1.0 while the sun is up in the Overworld, fading out around horizon
fn daylight() -> f32 {
    return select(0.0, smoothstep(-0.1, 0.15, frame.sun_direction.y), frame.dimension == 0);
}

// 1.0 when the sun is on the horizon (sunrise / sunset), 0.0 at noon or midnight
fn sun_low() -> f32 {
    return 1.0 - smoothstep(0.0, 0.38, abs(frame.sun_direction.y));
}
