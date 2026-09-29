shader_type canvas_item;

void fragment() {
    // Calculate the distance from the center of the node (0.5, 0.5)
    float distance_from_center = distance(UV, vec2(0.5));
    
    // Smoothly interpolate alpha from 1.0 at the center to 0.0 at the edge
    float alpha = smoothstep(0.5, 0.0, distance_from_center);
    
    // MODULATE contains the color you picked in the ColorRect's inspector
    // We keep its RGB channels and multiply its original alpha by our fade alpha
    COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
}