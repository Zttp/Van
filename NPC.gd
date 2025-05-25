extends CharacterBody3D  

# Настройки  
@export var dialogue_lines: Array[String] = ["Привет!", "Как дела?"]  
@export var move_speed: float = 2.0  # Если NPC движется  

var can_interact: bool = false  
var current_dialogue_index: int = 0  

# Ссылки на ноды  
@onready var animation_player = $AnimationPlayer  
@onready var interact_label = $InteractionArea/Label3D  

func _ready():  
    interact_label.visible = false  
    animation_player.play("idle")  

func _physics_process(delta):  
    if can_interact and Input.is_action_just_pressed("interact"):  
        start_dialogue()  

    # Если NPC должен патрулировать  
    # move_and_slide()  

func _on_interaction_area_body_entered(body):  
    if body.is_in_group("player"):  
        can_interact = true  
        interact_label.visible = true  

func _on_interaction_area_body_exited(body):  
    if body.is_in_group("player"):  
        can_interact = false  
        interact_label.visible = false  
        end_dialogue()  

func start_dialogue():  
    Global.ui.show_dialogue(dialogue_lines[current_dialogue_index])  
    animation_player.play("talk")  
    current_dialogue_index = (current_dialogue_index + 1) % dialogue_lines.size()  

func end_dialogue():  
    Global.ui.hide_dialogue()  
    animation_player.play("idle")  
