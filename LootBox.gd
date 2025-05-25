extends RigidBody3D  

@export var box_type: String = "common"  # "common", "rare", "legendary"  
@onready var loot_table = preload("res://scripts/loot_table.gd").new()  

func _ready():  
    $InteractArea.interact_text = "Открыть " + box_type  

func _on_interact():  
    var item = get_random_item()  
    Global.player_inventory.add_item(item)  
    spawn_open_effect()  
    queue_free()  

func get_random_item():  
    var rarity_roll = randf()  
    var target_pool = "common"  

    match box_type:  
        "common":  
            if rarity_roll < 0.01: target_pool = "rare"  
        "rare":  
            if rarity_roll < 0.05: target_pool = "legendary"  
        "legendary":  
            target_pool = "legendary"  

    return loot_table[target_pool].pick_random()  

func spawn_open_effect():  
    var particles = GPUParticles3D.new()  
    add_child(particles)  
    particles.emitting = true  
