override contrast: f32 = 1.12;
override water_tint: bool = true;

fn material(input: MaterialInput) -> Surface {
    // Sildur's lightmap enhancement
    var light = input.lightmap;

    // Warm up block light (torch, lantern, lava)
    let block_lvl = input.light.x;
    let torch_warmth = pow(block_lvl, 1.8) * vec3<f32>(1.08, 0.82, 0.45);
    light = mix(light, light * torch_warmth * 1.3, block_lvl * 0.45);

    // Apply contrast curve
    light = pow(light, vec3<f32>(contrast));

    var base_color = input.albedo * input.tint;

    // Sildur's translucent water tint
    if input.translucent && water_tint {
        let water_color = vec3<f32>(0.12, 0.65, 0.82);
        base_color = vec4<f32>(mix(base_color.rgb, water_color, 0.35), base_color.a * 0.85);
    }

    return Surface(base_color * vec4<f32>(light, 1.0));
}
