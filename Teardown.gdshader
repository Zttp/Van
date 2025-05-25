shader_type canvas_item;

// Настройки эффекта
uniform float pixelation_amount : hint_range(1.0, 50.0) = 10.0;
uniform float color_palette_size : hint_range(2.0, 16.0) = 8.0;
uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float bloom_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float edge_darkening : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.1;
uniform float noise_amount : hint_range(0.0, 0.1) = 0.02;

// Функция для квантования цвета
vec3 quantize_color(vec3 color, float levels) {
    return floor(color * levels + 0.5) / levels;
}

// Простой шум для добавления зернистости
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Функция для создания эффекта вокселизации
vec4 voxel_effect(sampler2D tex, vec2 uv, vec2 pixel_size) {
    // Определяем размер блока для вокселизации
    float block_size = pixelation_amount;
    vec2 block_uv = floor(uv * block_size) / block_size;
    
    // Получаем средний цвет блока
    vec4 color = texture(tex, block_uv);
    
    // Добавляем тень на нижнюю и правую грани
    vec2 block_pos = fract(uv * block_size);
    float shadow = 1.0 - max(0.0, (1.0 - block_pos.x) * shadow_intensity * 0.5 + 
                                   (1.0 - block_pos.y) * shadow_intensity);
    
    // Затемняем края для эффекта "воксельности"
    float edge = max(step(0.9, block_pos.x), step(0.9, block_pos.y));
    color.rgb *= mix(1.0, 1.0 - edge_darkening, edge) * shadow;
    
    return color;
}

// Функция для размытия (имитация низкого разрешения)
vec4 low_res_blur(sampler2D tex, vec2 uv, vec2 pixel_size) {
    vec4 sum = vec4(0.0);
    float samples = 0.0;
    
    // Простое размытие 3x3
    for (float x = -1.0; x <= 1.0; x++) {
        for (float y = -1.0; y <= 1.0; y++) {
            sum += texture(tex, uv + vec2(x, y) * pixel_size * 2.0);
            samples += 1.0;
        }
    }
    
    return sum / samples;
}

// Функция для эффекта bloom
vec4 apply_bloom(vec4 color, sampler2D tex, vec2 uv, vec2 pixel_size) {
    if (color.r > bloom_threshold || color.g > bloom_threshold || color.b > bloom_threshold) {
        vec4 bloom = vec4(0.0);
        float radius = 3.0;
        
        for (float x = -radius; x <= radius; x++) {
            for (float y = -radius; y <= radius; y++) {
                vec2 offset = vec2(x, y) * pixel_size * 2.0;
                vec4 sample_color = texture(tex, uv + offset);
                
                // Учитываем только яркие пиксели
                float brightness = dot(sample_color.rgb, vec3(0.2126, 0.7152, 0.0722));
                if (brightness > bloom_threshold) {
                    bloom += sample_color * (1.0 - length(offset) / (radius * pixel_size.x));
                }
            }
        }
        
        bloom = bloom / (radius * radius) * bloom_intensity;
        color += bloom;
    }
    
    return color;
}

void fragment() {
    // Получаем исходный UV и размер пикселя
    vec2 base_uv = UV;
    vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
    
    // Применяем воксельный эффект
    vec4 color = voxel_effect(TEXTURE, base_uv, pixel_size);
    
    // Добавляем размытие (имитация низкого разрешения)
    color = mix(color, low_res_blur(TEXTURE, base_uv, pixel_size), 0.3);
    
    // Квантуем цвета для ограниченной палитры
    color.rgb = quantize_color(color.rgb, color_palette_size);
    
    // Добавляем bloom эффект для ярких областей
    color = apply_bloom(color, TEXTURE, base_uv, pixel_size);
    
    // Добавляем scanlines (горизонтальные линии)
    float scanline = sin(SCREEN_UV.y * 1080.0 * 3.14159);
    color.rgb *= 1.0 - (scanline * scanline_opacity);
    
    // Добавляем немного шума для зернистости
    float noise = rand(SCREEN_UV + TIME) * noise_amount;
    color.rgb += vec3(noise) - noise_amount * 0.5;
    
    // Ограничиваем цвет
    color = clamp(color, 0.0, 1.0);
    
    COLOR = color;
}
