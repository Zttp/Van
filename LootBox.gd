extends RigidBody3D  

@export var box_type: String = "common"  
@export var loot_table: Resource # JSON/Resource с данными лута  
@onready var animation_player = $AnimationPlayer  

var is_opened = false  

func _ready():  
    # Настройка текста взаимодействия  
    $InteractArea/InteractLabel.text = "Нажми E чтобы открыть"  

func _on_interact():  
    if !is_opened:  
        is_opened = true  
        animation_player.play("open")  
        await animation_player.animation_finished  
        spawn_loot()  
        queue_free()  

func spawn_loot():  
    var item = loot_table.get_item(box_type)  
    var loot_scene = load(item.scene_path)  
    var loot_instance = loot_scene.instantiate()  
    loot_instance.global_transform = global_transform  
    get_parent().add_child(loot_instance)  

func _on_interact_area_body_entered(body):  
    if body.is_in_group("player"):  
        $InteractArea/InteractLabel.visible = true  

func _on_interact_area_body_exited(body):  
    if body.is_in_group("player"):  
        $InteractArea/InteractLabel.visible = false  
