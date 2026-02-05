extends Node2D

const BOARD_WIDTH := 10
const BOARD_HEIGHT := 20

var grid: Array[PackedByteArray] = []

@onready var tilemap: TileMapLayer = get_parent().get_node("TileMap")
@onready var piece_manager = get_parent().get_node("Piece_Manager")

func _ready() -> void:
	_init_board()
	_render_board()

func _init_board() -> void:
	grid.clear()
	for y in BOARD_HEIGHT:
		var row := PackedByteArray()
		row.resize(BOARD_WIDTH)
		row.fill(0)
		grid.append(row)

func _render_board() -> void:
	tilemap.clear()

	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			if grid[y][x] == 0:
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(3, 1))
			else:
				tilemap.set_cell(Vector2i(x, y), 0, piece_manager.sprites.get(grid[y][x]))

func _check_lines() -> void:
	var lines_cleared := 0
	for y in range(BOARD_HEIGHT):
		if grid[y].find(0) == -1: # No empty cells
			grid.remove_at(y)
			var new_row := PackedByteArray()
			new_row.resize(BOARD_WIDTH)
			new_row.fill(0)
			grid.insert(0, new_row)
			lines_cleared += 1
	if lines_cleared > 0:
		_render_board()
		get_parent().score += lines_cleared * 100