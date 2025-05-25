extends VehicleBody3D  

# Настройки двигателя  
@export var max_speed_kmh = 130.0  # Максималка (130 км/ч)  
@export var engine_power = 300.0    # Мощность двигателя  
@export var brake_power = 50.0      # Сила торможения  
@export var steering_speed = 1.5    # Скорость поворота руля  

# Коэффициенты заноса  
@export var drift_slip = 0.7       # Скольжение при заносе  
@export var drift_grip = 0.4       # Сцепление после заноса  

# Физические параметры  
var current_speed_kmh = 0.0  
var is_drifting = false  

func _ready():  
    # Настраиваем колёса  
    for wheel in get_children():  
        if wheel is VehicleWheel3D:  
            wheel.wheel_friction_slip = 4.0  # Стандартное сцепление  
            wheel.engine_force = 0  
            wheel.brake = 0  

func _physics_process(delta):  
    handle_input(delta)  
    update_speed()  
    apply_drift_effects()  

func handle_input(delta):  
    # Ускорение/торможение  
    var accelerate = Input.get_action_strength("accelerate")  
    var brake = Input.get_action_strength("brake")  
    var steer = Input.get_axis("steer_left", "steer_right")  

    # Конвертируем км/ч в м/с (для Godot)  
    var max_speed_ms = max_speed_kmh / 3.6  

    # Если текущая скорость меньше максимума — даём газу  
    if current_speed_kmh < max_speed_kmh:  
        engine_force = accelerate * engine_power  
    else:  
        engine_force = 0  # Не даём разогнаться больше  

    # Торможение  
    brake = brake * brake_power  

    # Поворот руля  
    steering = move_toward(steering, steer * 0.4, steering_speed * delta)  

    # Ручной тормоз (пробел)  
    if Input.is_action_pressed("handbrake"):  
        is_drifting = true  
        for wheel in get_children():  
            if wheel is VehicleWheel3D:  
                wheel.wheel_friction_slip = drift_slip  # Снижаем сцепление  
    else:  
        is_drifting = false  

func update_speed():  
    # Считаем скорость в км/ч  
    current_speed_kmh = linear_velocity.length() * 3.6  

func apply_drift_effects():  
    # Если занос закончился — возвращаем сцепление  
    if !is_drifting:  
        for wheel in get_children():  
            if wheel is VehicleWheel3D:  
                wheel.wheel_friction_slip = move_toward(wheel.wheel_friction_slip, 4.0, 0.1)  

    # Визуальные эффекты (дым из колёс, звук)  
    if is_drifting && current_speed_kmh > 30.0:  
        spawn_drift_smoke()  

func spawn_drift_smoke():  
    # Тут можно добавить систему частиц  
    pass  
