class_name InteractionSceneLayouts
extends RefCounted

## Per-scene art-direction map for scene-space targets. `p` is the normalized
## center inside the interaction field, `s` is its pixel hit size, `mode` is
## either an atlas prop or a transparent region over an element in the painted
## background, and `z` resolves intentional overlaps.

const DATA := {
	"c01_s01_room_morning": {
		"alarm": {"p": Vector2(0.13, 0.67), "s": Vector2(145, 128)},
		"cup": {"p": Vector2(0.35, 0.62), "s": Vector2(145, 126)},
		"shirt": {"p": Vector2(0.75, 0.21), "s": Vector2(164, 140)},
		"keys": {"p": Vector2(0.47, 0.69), "s": Vector2(144, 116)},
		"door_lock": {"p": Vector2(1.01, 0.45), "s": Vector2(150, 176), "z": 3},
	},
	"c01_s02_commute_window": {
		"window": {"p": Vector2(0.66, 0.39), "s": Vector2(430, 650), "mode": "region", "z": 0},
		"phone": {"p": Vector2(0.78, 0.68), "s": Vector2(220, 230), "z": 4},
		"headlight": {"p": Vector2(0.62, 0.48), "s": Vector2(150, 120), "mode": "region", "z": 3},
		"plate": {"p": Vector2(0.84, 0.56), "s": Vector2(150, 120), "mode": "region", "z": 3},
	},
	"c01_s03_night_car_array": {
		"car_round_eye": {"p": Vector2(0.34, 0.18), "s": Vector2(132, 100)},
		"car_sleepy_eye": {"p": Vector2(0.55, 0.17), "s": Vector2(132, 100)},
		"car_narrow_eye": {"p": Vector2(0.76, 0.21), "s": Vector2(132, 100)},
		"car_red_tail": {"p": Vector2(0.43, 0.40), "s": Vector2(132, 100)},
		"car_tiny_van": {"p": Vector2(0.67, 0.40), "s": Vector2(132, 100)},
		"friend_route": {"p": Vector2(0.28, 0.72), "s": Vector2(270, 132)},
		"enemy_route": {"p": Vector2(0.74, 0.72), "s": Vector2(270, 132)},
	},
	"c01_s05_signal_tower": {
		"green": {"p": Vector2(0.72, 0.33), "s": Vector2(158, 142)},
		"red": {"p": Vector2(0.85, 0.48), "s": Vector2(158, 142)},
	},
	"c01_s06_commute_echo": {
		"window": {"p": Vector2(0.65, 0.39), "s": Vector2(440, 640), "mode": "region", "z": 0},
		"red_light": {"p": Vector2(0.89, 0.31), "s": Vector2(150, 170), "mode": "region", "z": 2},
		"tree": {"p": Vector2(0.89, 0.51), "s": Vector2(170, 190), "mode": "region", "z": 2},
		"phone": {"p": Vector2(0.78, 0.68), "s": Vector2(216, 226), "z": 4},
	},

	"c02_s01_school_gate": {
		"gate": {"p": Vector2(0.52, 0.72), "s": Vector2(340, 240), "mode": "region"},
		"track_shadow": {"p": Vector2(0.50, 0.45), "s": Vector2(520, 430), "mode": "region"},
		"wall_corner": {"p": Vector2(0.83, 0.74), "s": Vector2(210, 250), "mode": "region"},
		"start_loop": {"p": Vector2(0.24, 0.73), "s": Vector2(185, 150), "mode": "region", "z": 2},
	},
	"c02_s03_playground_loop": {
		"track_line": {"p": Vector2(0.51, 0.45), "s": Vector2(520, 430), "mode": "region"},
		"chalk_corridor_shadow": {"p": Vector2(0.50, 0.68), "s": Vector2(154, 126)},
	},
	"c02_s04_chalk_corridor": {
		"hint_no_turn": {"p": Vector2(0.17, 0.70), "s": Vector2(145, 118), "mode": "region"},
		"hint_slow_fourth": {"p": Vector2(0.52, 0.75), "s": Vector2(170, 132), "mode": "region"},
		"hint_short_shadow": {"p": Vector2(0.83, 0.72), "s": Vector2(160, 140), "mode": "region"},
	},
	"c02_s05_desk_island": {
		"desk_mark": {"p": Vector2(0.81, 0.38), "s": Vector2(230, 160), "mode": "region"},
		"drawer_note": {"p": Vector2(0.88, 0.46), "s": Vector2(165, 132)},
	},
	"c02_s06_room_corner_echo": {
		"chalk": {"p": Vector2(0.31, 0.65), "s": Vector2(145, 116)},
		"star": {"p": Vector2(0.49, 0.63), "s": Vector2(145, 126)},
		"desk_corner": {"p": Vector2(0.73, 0.70), "s": Vector2(210, 160), "mode": "region"},
		"bag": {"p": Vector2(0.16, 0.77), "s": Vector2(170, 160)},
	},

	"c03_s01_bookshelf": {
		"old_manga": {"p": Vector2(0.27, 0.33), "s": Vector2(170, 145)},
		"pencil": {"p": Vector2(0.72, 0.34), "s": Vector2(145, 120)},
		"old_paper": {"p": Vector2(0.27, 0.56), "s": Vector2(178, 146)},
		"open_manga": {"p": Vector2(0.55, 0.13), "s": Vector2(190, 145)},
	},
	"c03_s03_book_spine_city": {
		"round_friend": {"p": Vector2(0.48, 0.83), "s": Vector2(170, 250), "mode": "region"},
		"brow_friend": {"p": Vector2(0.25, 0.82), "s": Vector2(180, 250), "mode": "region"},
		"bag_friend": {"p": Vector2(0.72, 0.82), "s": Vector2(180, 250), "mode": "region"},
		"panel_corridor": {"p": Vector2(0.54, 0.16), "s": Vector2(200, 150), "mode": "region"},
	},
	"c03_s04_panel_corridor": {
		"like": {"p": Vector2(0.20, 0.89), "s": Vector2(112, 92)},
		"wait": {"p": Vector2(0.40, 0.89), "s": Vector2(112, 92)},
		"proud": {"p": Vector2(0.60, 0.89), "s": Vector2(112, 92)},
		"bye": {"p": Vector2(0.80, 0.89), "s": Vector2(112, 92)},
		"order_0": {"p": Vector2(0.27, 0.34), "s": Vector2(225, 150), "mode": "region"},
		"order_1": {"p": Vector2(0.72, 0.36), "s": Vector2(225, 150), "mode": "region"},
		"order_2": {"p": Vector2(0.27, 0.57), "s": Vector2(225, 165), "mode": "region"},
		"order_3": {"p": Vector2(0.72, 0.58), "s": Vector2(225, 165), "mode": "region"},
	},
	"c03_s05_paper_theater": {
		"old_bookmark": {"p": Vector2(0.27, 0.73), "s": Vector2(150, 128)},
		"stage_gap": {"p": Vector2(0.55, 0.14), "s": Vector2(220, 150), "mode": "region"},
	},
	"c03_s06_new_book_echo": {
		"new_book": {"p": Vector2(0.28, 0.64), "s": Vector2(170, 148)},
		"bookmark": {"p": Vector2(0.47, 0.66), "s": Vector2(148, 126)},
		"pencil": {"p": Vector2(0.61, 0.63), "s": Vector2(145, 120)},
		"receipt": {"p": Vector2(0.76, 0.68), "s": Vector2(160, 134)},
	},

	"c04_s01_work_pressure": {
		"messages": {"p": Vector2(0.38, 0.67), "s": Vector2(160, 138)},
		"desk_drawer": {"p": Vector2(0.54, 0.82), "s": Vector2(310, 142), "mode": "region"},
		"overhead_light": {"p": Vector2(0.53, 0.08), "s": Vector2(240, 120), "mode": "region"},
		"close_laptop": {"p": Vector2(0.49, 0.68), "s": Vector2(210, 145), "mode": "region"},
	},
	"c04_s02_cabinet_doors": {
		"cabinet_door": {"p": Vector2(0.86, 0.53), "s": Vector2(210, 560), "mode": "region"},
	},
	"c04_s03_rain_classroom": {
		"rain": {"p": Vector2(0.35, 0.13), "s": Vector2(132, 100)},
		"steps": {"p": Vector2(0.53, 0.12), "s": Vector2(132, 100)},
		"breath": {"p": Vector2(0.71, 0.13), "s": Vector2(132, 100)},
		"window": {"p": Vector2(0.17, 0.32), "s": Vector2(225, 500), "mode": "region"},
		"door": {"p": Vector2(0.51, 0.43), "s": Vector2(150, 420), "mode": "region"},
		"bag": {"p": Vector2(0.18, 0.70), "s": Vector2(180, 190), "mode": "region", "z": 2},
	},
	"c04_s04_cabinet_islands": {
		"book_cabinet": {"p": Vector2(0.70, 0.35), "s": Vector2(180, 210), "mode": "region"},
		"leaf_cabinet": {"p": Vector2(0.86, 0.52), "s": Vector2(190, 500), "mode": "region"},
		"empty_cabinet": {"p": Vector2(0.68, 0.66), "s": Vector2(175, 210), "mode": "region"},
		"forest_shadow_door": {"p": Vector2(0.51, 0.45), "s": Vector2(165, 270), "mode": "region"},
	},
	"c04_s06_quiet_room_echo": {
		"phone": {"p": Vector2(0.78, 0.68), "s": Vector2(215, 224), "z": 4},
		"lamp": {"p": Vector2(0.83, 0.48), "s": Vector2(190, 180), "mode": "region"},
		"plastic_ruler": {"p": Vector2(0.55, 0.65), "s": Vector2(165, 124)},
		"chair": {"p": Vector2(0.23, 0.82), "s": Vector2(230, 205), "mode": "region"},
	},

	"c05_s01_forest_edge": {
		"old_school": {"p": Vector2(0.58, 0.16), "s": Vector2(300, 150), "mode": "region"},
		"forest_shadow": {"p": Vector2(0.20, 0.34), "s": Vector2(230, 250), "mode": "region"},
		"mud": {"p": Vector2(0.55, 0.52), "s": Vector2(260, 170), "mode": "region"},
		"forest_path": {"p": Vector2(0.57, 0.34), "s": Vector2(220, 280), "mode": "region", "z": 2},
	},
	"c05_s03_underground_classroom": {
		"blackboard": {"p": Vector2(0.25, 0.61), "s": Vector2(290, 240), "mode": "region"},
		"window": {"p": Vector2(0.66, 0.61), "s": Vector2(190, 190), "mode": "region"},
		"manga_page": {"p": Vector2(0.88, 0.68), "s": Vector2(170, 190), "mode": "region", "z": 2},
		"cabinet": {"p": Vector2(0.84, 0.76), "s": Vector2(190, 210), "mode": "region"},
		"fossil_table": {"p": Vector2(0.50, 0.82), "s": Vector2(320, 190), "mode": "region", "z": 3},
	},
	"c05_s04_impossible_fossil": {
		"fossil_box": {"p": Vector2(0.50, 0.78), "s": Vector2(260, 230), "mode": "region", "z": 3},
		"why_book": {"p": Vector2(0.74, 0.72), "s": Vector2(165, 140)},
		"old_mud": {"p": Vector2(0.63, 0.80), "s": Vector2(170, 135)},
	},
	"c05_s06_morning_echo": {
		"new_pen": {"p": Vector2(0.24, 0.64), "s": Vector2(150, 122)},
		"fossil": {"p": Vector2(0.48, 0.70), "s": Vector2(180, 150)},
		"marble": {"p": Vector2(0.67, 0.65), "s": Vector2(145, 124)},
		"window": {"p": Vector2(0.24, 0.31), "s": Vector2(330, 500), "mode": "region"},
		"arrange_items": {"p": Vector2(0.49, 0.71), "s": Vector2(330, 170), "mode": "region", "z": 3},
		"send_friend_message": {"p": Vector2(0.82, 0.68), "s": Vector2(220, 230), "z": 4},
	},
}


static func target(scene_id: String, target_id: String) -> Dictionary:
	var scene_layout: Dictionary = DATA.get(scene_id, {})
	var placement: Dictionary = scene_layout.get(target_id, {})
	return placement.duplicate(true)
