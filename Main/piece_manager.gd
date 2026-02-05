extends Node
class_name PieceManager

class PieceData:

    var piece_id: int
    var base_coords: Array[Vector2i]

    func _init(id: int, coords: Array[Vector2i]):
        piece_id = id   
        base_coords = coords

var sprites : Dictionary = {
    1: Vector2i(2, 0),
    2: Vector2i(1, 0),
    3: Vector2i(2, 1),
    4: Vector2i(1, 1),
    5: Vector2i(3, 0),
    6: Vector2i(0, 1),
    7: Vector2i(0, 0)
}

var pieces: Dictionary = {}

func _ready() -> void:
    _register_pieces()

func _register_pieces() -> void:
    pieces["I"] = PieceData.new(1, [Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)])
    pieces["O"] = PieceData.new(2, [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(-1, 1)])
    pieces["T"] = PieceData.new(3, [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)])
    pieces["S"] = PieceData.new(4, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1)])
    pieces["Z"] = PieceData.new(5, [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)])
    pieces["J"] = PieceData.new(6, [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)])
    pieces["L"] = PieceData.new(7, [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1)])
