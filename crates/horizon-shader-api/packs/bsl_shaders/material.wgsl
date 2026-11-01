override contrast: f32 = 1.15;
override water_translucency: bool = true;

fn material(input: MaterialInput) -> Surface {
    var light = input.lightmap;

    // BSL Iconic Warm Torchlight / Blocklight
    let block_light = input.light.x;
    let torch_color = vec3<f32>(1.0, 0.52, 0.16);
    let torch_intensity = pow(block_light, 1.7) * 0.52;
    light = mix(light, light * torch_color * 1.38, torch_intensity);

    // BSL Ambient Cool Shadows vs Warm Sunlight
    let sky_light = input.light.y;
    let day = daylight();
    let ambient_cool = vec3<f32>(0.82, 0.90, 1.05);
    let sun_warm = vec3<f32>(1.06, 1.02, 0.94);
    let sun_shadow_balance = mix(ambient_cool, sun_warm, sky_light * day);
    light *= sun_shadow_balance;

    // BSL Contrast Curve
    light = pow(light, vec3<f32>(contrast));

    var base_color = input.albedo * input.tint;

    // BSL Signature Crystal Water
    if input.translucent && water_translucency {
        let bsl_water = vec3<f32>(0.08, 0.72, 0.85);
        base_color = vec4<f32>(mix(base_color.rgb, bsl_water, 0.40), base_color.a * 0.82);
    }

    return Surface(base_color * vec4<f32>(light, 1.0));
}
