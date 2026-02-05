extends Node2D

@onready var board = $Board
@onready var piece_manager = $Piece_Manager
@onready var tile_map = $TileMap

var score := 0
var has_switched := false # Wether the player has used switch piece this turn

var current_piece: PieceManager.PieceData = null
var current_piece_coords : Array[Vector2i] = ([Vector2i(0, 0)])
var current_piece_offset := Vector2i(4, 1) 

var next_piece: PieceManager.PieceData = null
var stored_piece : PieceManager.PieceData = null

var piece_bag: Array[String] = []
var bag_index := 0

# Game tick timers
const TICK_INTERVAL := 1.0
var tick_timer := 0.0

# Control delay timers
const DAS_DELAY := 0.2
const DAS_REPEAT := 0.1 
const DAS_REPEAT_DOWN := 0.05
var das_timer_left := 0.0
var das_timer_right := 0.0
var das_timer_down := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refill_bag()
	next_piece = get_piece()
	spawn_piece()

# Piece randomization and spawn logic

func get_piece() -> PieceManager.PieceData:
	if bag_index >= piece_bag.size():
		refill_bag()
	var piece_key = piece_bag[bag_index]
	bag_index += 1
	return piece_manager.pieces.get(piece_key)

func refill_bag() -> void:
	piece_bag = []
	for key in piece_manager.pieces.keys():
		piece_bag.append(key)
	randomize()
	piece_bag.shuffle()
	print(piece_bag)
	bag_index = 0

func spawn_piece() -> void:

	current_piece = next_piece
	next_piece = get_piece()
	current_piece_coords = current_piece.base_coords.duplicate()
	current_piece_offset = Vector2i(4, 1)
	_render_current_piece()

func switch_piece() -> void:
	var temp = stored_piece
	stored_piece = current_piece
	current_piece = temp
	current_piece_coords = current_piece.base_coords.duplicate()
	current_piece_offset = Vector2i(4, 1)
	_render_current_piece()

enum Commands {
	RIGHT,
	DOWN,
	LEFT,
	ROTATE_CLOCKWISE,
	ROTATE_COUNTERCLOCKWISE,
	STORE
}

func check_valid_move(command: Commands) -> bool:
	var new_offset : Vector2i = current_piece_offset
	match command:
		Commands.LEFT:
			new_offset.x -= 1
		Commands.RIGHT:
			new_offset.x += 1
		Commands.DOWN:
			new_offset.y += 1
		Commands.ROTATE_CLOCKWISE:
			pass
		Commands.ROTATE_COUNTERCLOCKWISE:
			pass
		Commands.STORE:
			pass

	for cell in current_piece_coords:
		var pos := new_offset + cell
		if pos.x < 0 or pos.x >= board.BOARD_WIDTH:
				return false
		if pos.y >= board.BOARD_HEIGHT:
			return false		
		if board.grid[pos.y][pos.x] != 0:
			return false
	return true

func piece_place() -> void:
	has_switched = false
	for cell in current_piece_coords:
		var pos: Vector2i = cell + current_piece_offset
		board.grid[pos.y][pos.x] = current_piece.piece_id
	board._check_lines()
	spawn_piece()

func piece_fall() -> void: # Once every tick
	if check_valid_move(Commands.DOWN):
		current_piece_offset.y += 1
	else:
		piece_place()

func move_piece(command: Commands) -> void:
	if check_valid_move(command):
		match command:
			Commands.LEFT:
				current_piece_offset.x -= 1
			Commands.RIGHT:
				current_piece_offset.x += 1
			Commands.DOWN:
				current_piece_offset.y += 1
	else:
		pass

func rotate_piece(command: Commands) -> void:
	var rotated: Array[Vector2i] = []
	match command:
		Commands.ROTATE_CLOCKWISE:
			for cell in current_piece_coords:
				rotated.append(Vector2i(-cell.y, cell.x))
		Commands.ROTATE_COUNTERCLOCKWISE:
			for cell in current_piece_coords:
				rotated.append(Vector2i(cell.y, -cell.x))
	current_piece_coords = rotated
	_render_current_piece()

# Input

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rotate_clockwise"):
		rotate_piece(Commands.ROTATE_CLOCKWISE)
	
	elif event.is_action_pressed("rotate_counterclockwise"):
		rotate_piece(Commands.ROTATE_COUNTERCLOCKWISE)

	elif event.is_action_pressed("space"):
		while check_valid_move(Commands.DOWN):
			current_piece_offset.y += 1
			score += 2
		piece_place()
		_render_current_piece()

	elif event.is_action_pressed("down"):
		move_piece(Commands.DOWN)
		das_timer_down = (DAS_REPEAT_DOWN)
		_render_current_piece()
	
	elif event.is_action_pressed("left"):
		move_piece(Commands.LEFT)
		das_timer_left = DAS_DELAY
		_render_current_piece()

	elif event.is_action_pressed("right"):
		move_piece(Commands.RIGHT)
		das_timer_right = DAS_DELAY
		_render_current_piece()

	elif event.is_action_pressed("store"):
		if not has_switched:
			has_switched = true
			if stored_piece == null:
				stored_piece = current_piece
				spawn_piece()
			else:
				switch_piece()
			has_switched = true


# Renderization

func _render_current_piece() -> void:
	board._render_board()

	for cell in current_piece_coords:
		var pos: Vector2i = cell + current_piece_offset
		tile_map.set_cell(pos, 0, piece_manager.sprites.get(current_piece.piece_id))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Game tick clock
	tick_timer += delta
	if tick_timer >= TICK_INTERVAL:
		tick_timer = 0.0
		_game_tick()
	
	# Hold controls
	if Input.is_action_pressed("left"):
		das_timer_left -= delta
		if das_timer_left <= 0.0:
			move_piece(Commands.LEFT)
			_render_current_piece()
			das_timer_left = DAS_REPEAT

	if Input.is_action_pressed("right"):
		das_timer_right -= delta
		if das_timer_right <= 0.0:
			move_piece(Commands.RIGHT)
			_render_current_piece()
			das_timer_right = DAS_REPEAT

	if Input.is_action_pressed("down"):
		das_timer_down -= delta
		if das_timer_down <= 0.0:
			move_piece(Commands.DOWN)
			score += 1
			_render_current_piece()
			das_timer_down = DAS_REPEAT_DOWN

func _game_tick() -> void:
	piece_fall()
	_render_current_piece()
