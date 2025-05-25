extends Node3D

@export var available_items: Array[String] = ["fuel", "tools", "food"]
@export var prices: Dictionary = {"fuel": 150, "tools": 300, "food": 50}
@export var restock_hours: int = 24

var current_stock: Dictionary = {}
var last_restock_time: int = 0

@onready var merchant = $NPCs/Merchant
@onready var trade_ui = $UI_Anchor/TradeUI
@onready var loot_spawn = $Buildings/Storage/LootSpawnPoint

func _ready():
    restock_items()
    merchant.connect("on_interact", _on_merchant_interact)
    
    # Загружаем сохранённое состояние
    if SaveSystem.save_exists("trading_post"):
        load_state()

func restock_items():
    for item in available_items:
        current_stock[item] = randi_range(3, 10)
    last_restock_time = Time.get_unix_time_from_system()

func _on_merchant_interact():
    if Time.get_unix_time_from_system() - last_restock_time > restock_hours * 3600:
        restock_items()
    
    update_ui()
    trade_ui.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func update_ui():
    trade_ui.clear()
    for item in current_stock:
        if current_stock[item] > 0:
            trade_ui.add_item(f"{item} (${prices[item]}) - {current_stock[item]} left")

func purchase_item(item_name: String):
    if current_stock.get(item_name, 0) > 0:
        if Global.player_money >= prices[item_name]:
            Global.player_money -= prices[item_name]
            current_stock[item_name] -= 1
            spawn_item(item_name)
            update_ui()
            SaveSystem.save_game()

func spawn_item(item_name: String):
    var item_scene = load(f"res://items/{item_name}.tscn")
    var item = item_scene.instantiate()
    item.global_transform = loot_spawn.global_transform
    get_parent().add_child(item)

func _on_player_left():
    trade_ui.visible = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func save_state():
    var data = {
        "current_stock": current_stock,
        "last_restock": last_restock_time
    }
    SaveSystem.save_data("trading_post", data)

func load_state():
    var data = SaveSystem.load_data("trading_post")
    current_stock = data["current_stock"]
    last_restock_time = data["last_restock"]
