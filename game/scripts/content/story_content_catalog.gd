class_name StoryContentCatalog
extends RefCounted

## Five-chapter runtime story catalog for Godot 4.7.1.
##
## Load without an autoload:
##     const StoryCatalog = preload("res://scripts/content/story_content_catalog.gd")
##     var scene := StoryCatalog.get_scene("c01_s01_room_morning")
##
## Returned dictionaries are deep copies so UI code cannot mutate the source data.

const CHAPTER_ORDER := [
	"01_grey_morning",
	"02_looping_school",
	"03_paper_friends",
	"04_cabinet_breath",
	"05_after_forest",
]

const VALID_PHASES := ["opening", "entry", "inner_world", "echo"]

## These values are renderer contracts. UI code should branch on these stable keys,
## while chapter-specific targets, counts, gestures and ordering live in `interaction`.
const VALID_INTERACTION_TYPES := [
	"hotspot_sequence",
	"repeat_observe",
	"sort_targets",
	"path_route",
	"rhythm_sequence",
	"echo_revisit",
	"repeat_path",
	"path_trace",
	"collect_clues",
	"trace_lines",
	"reorder_sequence",
	"drag_place",
	"repeat_toggle",
	"slot_placement",
	"compare_spaces",
	"posture_sequence",
	"multi_touch_sequence",
]

const COLLECTIBLES := {
	"candy_badge": {
		"name": "糖纸徽章",
		"chapter_id": "01_grey_morning",
		"description": "透明的糖纸，被折成一枚很小的徽章。",
	},
	"eraser_crumb": {
		"name": "橡皮碎屑",
		"chapter_id": "02_looping_school",
		"description": "一点点橡皮屑，像旧学校掉下来的雪。",
	},
	"half_chalk": {
		"name": "半截粉笔",
		"chapter_id": "02_looping_school",
		"description": "太短了，但还够画一小段。",
	},
	"sticker_star": {
		"name": "贴纸星星",
		"chapter_id": "02_looping_school",
		"description": "星星边缘翘起来，还是亮的。",
	},
	"character_sticker": {
		"name": "角色贴纸",
		"chapter_id": "03_paper_friends",
		"description": "贴纸边缘翘了，但还粘得住。",
	},
	"old_bookmark": {
		"name": "旧书签",
		"chapter_id": "03_paper_friends",
		"description": "夹过很多页，也等过很久。",
	},
	"plastic_ruler": {
		"name": "透明塑料尺",
		"chapter_id": "04_cabinet_breath",
		"description": "透明、安静，像一条可以藏起来的边。",
	},
	"glass_marble": {
		"name": "玻璃弹珠",
		"chapter_id": "05_after_forest",
		"description": "一颗小小的玻璃弹珠，把灰色折出一点颜色。",
	},
	"impossible_fossil": {
		"name": "不可能的化石",
		"chapter_id": "05_after_forest",
		"description": "没成功，但很认真。",
	},
}

const CHAPTERS := {
	"01_grey_morning": {
		"id": "01_grey_morning",
		"number": 1,
		"title": "灰色早晨",
		"theme": "我已经多久没有认真看世界了？",
		"scene_ids": [
			"c01_s01_room_morning",
			"c01_s02_commute_window",
			"c01_s03_night_car_array",
			"c01_s04_backseat_fort",
			"c01_s05_signal_tower",
			"c01_s06_commute_echo",
		],
		"completion": {
			"perception_stage": "chapter_01_echo",
			"unlock_chapter": "02_looping_school",
			"visited_echo": "c01_commute_echo",
		},
	},
	"02_looping_school": {
		"id": "02_looping_school",
		"number": 2,
		"title": "绕完这一圈",
		"theme": "跑着跑着，世界好像在变……",
		"scene_ids": [
			"c02_s01_school_gate",
			"c02_s02_outer_loop",
			"c02_s03_playground_loop",
			"c02_s04_chalk_corridor",
			"c02_s05_desk_island",
			"c02_s06_room_corner_echo",
		],
		"completion": {
			"perception_stage": "chapter_02_echo",
			"unlock_chapter": "03_paper_friends",
			"visited_echo": "c02_room_corner_echo",
		},
	},
	"03_paper_friends": {
		"id": "03_paper_friends",
		"number": 3,
		"title": "纸片朋友",
		"theme": "那时候以为，他们会永远陪着我。",
		"scene_ids": [
			"c03_s01_bookshelf",
			"c03_s02_page_tracing",
			"c03_s03_book_spine_city",
			"c03_s04_panel_corridor",
			"c03_s05_paper_theater",
			"c03_s06_new_book_echo",
		],
		"completion": {
			"perception_stage": "chapter_03_echo",
			"unlock_chapter": "04_cabinet_breath",
			"visited_echo": "c03_new_book_echo",
		},
	},
	"04_cabinet_breath": {
		"id": "04_cabinet_breath",
		"number": 4,
		"title": "柜子里的呼吸",
		"theme": "那个让我安心的角落去哪了？",
		"scene_ids": [
			"c04_s01_work_pressure",
			"c04_s02_cabinet_doors",
			"c04_s03_rain_classroom",
			"c04_s04_cabinet_islands",
			"c04_s05_forest_edge_hide",
			"c04_s06_quiet_room_echo",
		],
		"completion": {
			"perception_stage": "chapter_04_echo",
			"unlock_chapter": "05_after_forest",
			"visited_echo": "c04_quiet_room_echo",
		},
	},
	"05_after_forest": {
		"id": "05_after_forest",
		"number": 5,
		"title": "密林之后",
		"theme": "前面还有啥呢？",
		"scene_ids": [
			"c05_s01_forest_edge",
			"c05_s02_tree_shadow_path",
			"c05_s03_underground_classroom",
			"c05_s04_impossible_fossil",
			"c05_s05_finger_stage",
			"c05_s06_morning_echo",
		],
		"completion": {
			"perception_stage": "ending_echo",
			"unlock_chapter": "",
			"visited_echo": "c05_morning_echo",
		},
	},
}

const SCENES := {
	# Chapter 1: 灰色早晨
	"c01_s01_room_morning": {
		"id": "c01_s01_room_morning",
		"chapter_id": "01_grey_morning",
		"title": "早晨房间",
		"phase": "opening",
		"narrative": "早晨没有坏到哪里去。只是每一样东西都像已经安排好了。",
		"background_key": "bg_c01_room_morning",
		"interaction_type": "hotspot_sequence",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["alarm", "cup", "shirt", "keys", "door_lock"],
			"required_count": 4,
			"finish_target_id": "door_lock",
		},
		"objective": "闹钟停了，杯子和衬衫各归原位。钥匙在桌边，门锁还没响。",
		"hint": "钥匙碰上桌面，门锁才发出熟悉的咔哒声。",
		"completion_feedback": "门锁咔哒一声。一天被平平整整地推开。",
		"collectibles": [],
		"next_scene_id": "c01_s02_commute_window",
	},
	"c01_s02_commute_window": {
		"id": "c01_s02_commute_window",
		"chapter_id": "01_grey_morning",
		"title": "通勤车窗",
		"phase": "entry",
		"narrative": "他本来只是抬头看了一眼。可那些灯，好像真的有表情。",
		"background_key": "bg_c01_commute_window",
		"interaction_type": "repeat_observe",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["window"],
			"repeat_count": 3,
			"optional_target_ids": ["phone", "headlight", "plate"],
		},
		"objective": "车窗里的灯原本只是灯。玻璃反光一晃，它们便有了眼睛。",
		"hint": "每当手机屏幕暗下去，玻璃上的身影就矮一点。",
		"completion_feedback": "前面的车灯眨了一下，玻璃里的身影矮了一点。",
		"collectibles": [],
		"next_scene_id": "c01_s03_night_car_array",
	},
	"c01_s03_night_car_array": {
		"id": "c01_s03_night_car_array",
		"chapter_id": "01_grey_morning",
		"title": "夜路车阵",
		"phase": "inner_world",
		"narrative": "车灯长出眼睛，车牌抿起嘴。夜路忽然分出了阵营。",
		"background_key": "bg_c01_night_car_array",
		"interaction_type": "sort_targets",
		"interaction": {
			"gesture": "drag",
			"slots": ["friend_route", "enemy_route"],
			"assignments": {
				"car_round_eye": "friend_route",
				"car_sleepy_eye": "friend_route",
				"car_narrow_eye": "enemy_route",
				"car_red_tail": "enemy_route",
				"car_tiny_van": "friend_route",
			},
		},
		"objective": "五辆车挤在夜路上，各自等着属于自己的队伍。",
		"hint": "圆圆的灯不吓人；眯起来的那双眼睛一直盯着这里。",
		"completion_feedback": "友军走左边，坏家伙去了旁边；路面亮起一条安全路线。",
		"collectibles": [],
		"next_scene_id": "c01_s04_backseat_fort",
	},
	"c01_s04_backseat_fort": {
		"id": "c01_s04_backseat_fort",
		"chapter_id": "01_grey_morning",
		"title": "后座堡垒",
		"phase": "inner_world",
		"narrative": "膝盖顶着前座，安全带横过胸口。后座却有四面看不见的墙。",
		"background_key": "bg_c01_backseat_fort",
		"interaction_type": "path_route",
		"interaction": {
			"gesture": "drag",
			"handle_id": "seatbelt_pin",
			"avoid_ids": ["enemy_node_a", "enemy_node_b"],
			"finish_target_id": "route_confirm",
		},
		"objective": "安全带扣像一枚小小的指挥针，座椅缝里藏着一条暗路。",
		"hint": "亮处会暴露行踪，座椅缝正好绕开那两道视线。",
		"completion_feedback": "路线贴着窗边拐开，友军安静地通过。",
		"collectibles": ["candy_badge"],
		"next_scene_id": "c01_s05_signal_tower",
	},
	"c01_s05_signal_tower": {
		"id": "c01_s05_signal_tower",
		"chapter_id": "01_grey_morning",
		"title": "信号灯塔",
		"phase": "inner_world",
		"narrative": "没有爆炸，也没有胜利音乐。只有灯光替等待的车辆打出一串小孩口令。",
		"background_key": "bg_c01_signal_tower",
		"interaction_type": "rhythm_sequence",
		"interaction": {
			"gesture": "tap",
			"input_ids": ["green", "red"],
			"required_order": ["green", "green", "red", "green"],
			"reset_on_error": true,
		},
		"objective": "绿灯短短亮两次，红灯拦一下，绿灯再把车送出去。",
		"hint": "走、走，停。绿灯收尾。",
		"completion_feedback": "友军越过路口，敌军岔路一盏盏暗下；夜路的声音忽然清楚。",
		"collectibles": [],
		"next_scene_id": "c01_s06_commute_echo",
	},
	"c01_s06_commute_echo": {
		"id": "c01_s06_commute_echo",
		"chapter_id": "01_grey_morning",
		"title": "第二天通勤",
		"phase": "echo",
		"narrative": "同一趟车，同一条路。今天友军好像比昨天多一点。",
		"background_key": "bg_c01_commute_echo",
		"interaction_type": "echo_revisit",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["window", "red_light", "tree", "phone"],
			"required_count": 3,
		},
		"objective": "手机还在掌心。红灯、车窗和树影却比昨天清楚。",
		"hint": "树影正跟着车走。",
		"completion_feedback": "树影跟着车走了一小段。他没有马上低头。",
		"collectibles": [],
		"next_scene_id": "",
	},

	# Chapter 2: 绕完这一圈
	"c02_s01_school_gate": {
		"id": "c02_s01_school_gate",
		"chapter_id": "02_looping_school",
		"title": "傍晚校门",
		"phase": "opening",
		"narrative": "他只是路过。可脚步自己慢了一点。",
		"background_key": "bg_c02_school_gate",
		"interaction_type": "hotspot_sequence",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["gate", "track_shadow", "wall_corner"],
			"required_count": 3,
			"finish_target_id": "start_loop",
		},
		"objective": "校门关了一半，跑道影子贴在墙里；外墙的拐角还往前延伸。",
		"hint": "墙根有一条刚够脚步跟上的细线。",
		"completion_feedback": "墙边浮出一条细线，脚步顺着它走出画面。",
		"collectibles": [],
		"next_scene_id": "c02_s02_outer_loop",
	},
	"c02_s02_outer_loop": {
		"id": "c02_s02_outer_loop",
		"chapter_id": "02_looping_school",
		"title": "外墙绕行",
		"phase": "entry",
		"narrative": "鞋底一快，学校就紧紧合着；摩擦声一拖长，墙缝里便飘出粉笔灰。",
		"background_key": "bg_c02_outer_loop",
		"interaction_type": "repeat_path",
		"interaction": {
			"gesture": "drag_hold",
			"path_id": "outer_wall_loop",
			"repeat_count": 4,
			"final_pace": "slow",
		},
		"objective": "一圈、两圈、三圈。第四圈的鞋底声拖长，学校才松开一点。",
		"hint": "粉笔灰贴着那道拖长的脚印，没有立刻散掉。",
		"completion_feedback": "外墙、光线和路面错开一点，学校轻轻松了一口气。",
		"collectibles": [],
		"next_scene_id": "c02_s03_playground_loop",
	},
	"c02_s03_playground_loop": {
		"id": "c02_s03_playground_loop",
		"chapter_id": "02_looping_school",
		"title": "操场环线",
		"phase": "inner_world",
		"narrative": "跑道被从两端轻轻拉长，只有内圈的慢路肯显出粉笔线。",
		"background_key": "bg_c02_playground_loop",
		"interaction_type": "path_trace",
		"interaction": {
			"gesture": "slow_drag",
			"path_id": "inner_lane",
			"prerequisite_target_id": "track_line",
			"finish_target_id": "chalk_corridor_shadow",
		},
		"objective": "跑道外圈笔直得没有破绽，内圈那条旧线却在向前生长。",
		"hint": "贴着内圈的线，别赶过自己的影子。",
		"completion_feedback": "粉笔线从脚边伸远，走廊影子在终点立起来。",
		"collectibles": ["eraser_crumb"],
		"next_scene_id": "c02_s04_chalk_corridor",
	},
	"c02_s04_chalk_corridor": {
		"id": "c02_s04_chalk_corridor",
		"chapter_id": "02_looping_school",
		"title": "粉笔走廊",
		"phase": "inner_world",
		"narrative": "字很笨，线条很轻，却认真得不容置疑。",
		"background_key": "bg_c02_chalk_corridor",
		"interaction_type": "collect_clues",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["hint_no_turn", "hint_slow_fourth", "hint_short_shadow"],
			"required_count": 3,
		},
		"objective": "墙上三处粉笔痕还没被风擦净。",
		"hint": "这里先别拐。第四圈慢一点。影子短的那边。",
		"completion_feedback": "三条粉笔线同时亮起，远处的课桌抽屉响了一声。",
		"collectibles": [],
		"next_scene_id": "c02_s05_desk_island",
	},
	"c02_s05_desk_island": {
		"id": "c02_s05_desk_island",
		"chapter_id": "02_looping_school",
		"title": "旧课桌岛",
		"phase": "inner_world",
		"narrative": "桌面划痕不是完整地图，只是一群小路在互相示意。",
		"background_key": "bg_c02_desk_island",
		"interaction_type": "path_trace",
		"interaction": {
			"gesture": "tap_then_slow_drag",
			"clue_ids": ["desk_mark", "drawer_note"],
			"required_clue_count": 2,
			"path_id": "desk_scratch_path",
		},
		"objective": "桌面两处旧痕互相接上，木纹便成了一条回到开头的小路。",
		"hint": "抽屉里的纸条只写着：跑慢点。",
		"completion_feedback": "划痕绕回一个桌角，现实房间的桌面从木纹里叠了上来。",
		"collectibles": ["half_chalk", "sticker_star"],
		"next_scene_id": "c02_s06_room_corner_echo",
	},
	"c02_s06_room_corner_echo": {
		"id": "c02_s06_room_corner_echo",
		"chapter_id": "02_looping_school",
		"title": "房间角落",
		"phase": "echo",
		"narrative": "桌面还是桌面，那一小块角落却像留给另一个自己坐一下。",
		"background_key": "bg_c02_room_corner_echo",
		"interaction_type": "echo_revisit",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["chalk", "star", "desk_corner", "bag"],
			"required_count": 2,
		},
		"objective": "粉笔、星星和空着的桌角，都在等一个很小的位置。",
		"hint": "粉笔很短，星星也很小。桌角还放得下。",
		"completion_feedback": "原来我以前真的很会玩。",
		"collectibles": [],
		"next_scene_id": "",
	},

	# Chapter 3: 纸片朋友
	"c03_s01_bookshelf": {
		"id": "c03_s01_bookshelf",
		"chapter_id": "03_paper_friends",
		"title": "旧书架",
		"phase": "opening",
		"narrative": "纸页有旧书和灰尘的味道。他的手指停在卷起的页角。",
		"background_key": "bg_c03_bookshelf",
		"interaction_type": "hotspot_sequence",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["old_manga", "pencil", "old_paper"],
			"required_count": 3,
			"finish_target_id": "open_manga",
		},
		"objective": "旧漫画露出卷边。钝铅笔和画过线的纸，还散在附近。",
		"hint": "卷边的漫画压着旧纸，钝铅笔滚到书脊旁。",
		"completion_feedback": "临摹纸盖到漫画页上，铅笔痕迹重新显出来。",
		"collectibles": [],
		"next_scene_id": "c03_s02_page_tracing",
	},
	"c03_s02_page_tracing": {
		"id": "c03_s02_page_tracing",
		"chapter_id": "03_paper_friends",
		"title": "翻页与临摹",
		"phase": "entry",
		"narrative": "线条抖着，比例也不准；喜欢却已经从纸边满了出来。",
		"background_key": "bg_c03_page_tracing",
		"interaction_type": "trace_lines",
		"interaction": {
			"gesture": "drag_trace",
			"line_ids": ["face", "hand", "bag"],
			"required_count": 3,
			"tolerance": "wide",
		},
		"objective": "脸、手和书包的三段轮廓断在纸上，铅笔尖落在第一道灰线旁。",
		"hint": "旧线本来就是歪的，铅笔尖正好落进那道灰痕。",
		"completion_feedback": "角色眨眼、挥手，临摹纸边缘站了起来。",
		"collectibles": [],
		"next_scene_id": "c03_s03_book_spine_city",
	},
	"c03_s03_book_spine_city": {
		"id": "c03_s03_book_spine_city",
		"chapter_id": "03_paper_friends",
		"title": "书脊城市",
		"phase": "inner_world",
		"narrative": "书脊成了街道，目录和页码成了街牌，扭歪的朋友在纸风里等着。",
		"background_key": "bg_c03_book_spine_city",
		"interaction_type": "collect_clues",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["round_friend", "brow_friend", "bag_friend"],
			"required_count": 3,
			"finish_target_id": "panel_corridor",
		},
		"objective": "三张画歪了的朋友，藏在高高低低的书脊之间。",
		"hint": "圆脸、粗眉毛、会飞的书包——页码记不住他们的路。",
		"completion_feedback": "三个纸片朋友贴到悬空分镜边缘，朝走廊跑去。",
		"collectibles": ["character_sticker"],
		"next_scene_id": "c03_s04_panel_corridor",
	},
	"c03_s04_panel_corridor": {
		"id": "c03_s04_panel_corridor",
		"chapter_id": "03_paper_friends",
		"title": "分镜走廊",
		"phase": "inner_world",
		"narrative": "格子不按页码相连，而按心里先后亮起来的地方相连。",
		"background_key": "bg_c03_panel_corridor",
		"interaction_type": "reorder_sequence",
		"interaction": {
			"gesture": "tap_clue_then_drag",
			"card_ids": ["like", "wait", "proud", "bye"],
			"required_order": ["like", "wait", "proud", "bye"],
		},
		"objective": "四格散开的画面，不认页码，只记得喜欢、期待、得意和告别。",
		"hint": "最舍不得翻过去的那张脸，总在最前面。",
		"completion_feedback": "四种纸声连成一小段旋律，分镜铺成通往剧场的路。",
		"collectibles": [],
		"next_scene_id": "c03_s05_paper_theater",
	},
	"c03_s05_paper_theater": {
		"id": "c03_s05_paper_theater",
		"chapter_id": "03_paper_friends",
		"title": "纸片剧场",
		"phase": "inner_world",
		"narrative": "纸箱舞台缺一小块路，旧书签恰好可以让朋友走到谢幕的位置。",
		"background_key": "bg_c03_paper_theater",
		"interaction_type": "drag_place",
		"interaction": {
			"gesture": "drag",
			"source_id": "old_bookmark",
			"slot_id": "stage_gap",
			"finish_target_id": "friend_bow",
		},
		"objective": "舞台缺了一截路。侧边那张旧书签，长度刚好。",
		"hint": "纸片朋友停在缺口前，谢幕的位置就在对面。",
		"completion_feedback": "纸片朋友把旧书签递回来：画歪了，也还是我们。",
		"collectibles": ["old_bookmark"],
		"next_scene_id": "c03_s06_new_book_echo",
	},
	"c03_s06_new_book_echo": {
		"id": "c03_s06_new_book_echo",
		"chapter_id": "03_paper_friends",
		"title": "新书回声",
		"phase": "echo",
		"narrative": "新漫画摊在桌上，旧书签夹在第一页，铅笔在页边留下一道歪线。",
		"background_key": "bg_c03_new_book_echo",
		"interaction_type": "echo_revisit",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["new_book", "bookmark", "pencil", "receipt"],
			"required_count": 2,
		},
		"objective": "新书、旧书签、铅笔和收据都留在桌上，像两个时间碰了面。",
		"hint": "看着顺眼的那本，已经翻开了。",
		"completion_feedback": "画歪了。但看得出来很喜欢。",
		"collectibles": [],
		"next_scene_id": "",
	},

	# Chapter 4: 柜子里的呼吸
	"c04_s01_work_pressure": {
		"id": "c04_s01_work_pressure",
		"chapter_id": "04_cabinet_breath",
		"title": "工位夜晚",
		"phase": "opening",
		"narrative": "他不是想消失。只是想先不要被任何声音碰到。",
		"background_key": "bg_c04_work_pressure",
		"interaction_type": "hotspot_sequence",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["messages", "desk_drawer", "overhead_light"],
			"required_count": 3,
			"finish_target_id": "close_laptop",
		},
		"objective": "消息挤在屏幕里，顶灯白得发硬；抽屉缝却吞掉了一点声音。",
		"hint": "提示音挤在屏幕上，抽屉发闷，顶灯嗡嗡响。",
		"completion_feedback": "电脑合上，声音缩小；抽屉缝变成一条柜门缝。",
		"collectibles": [],
		"next_scene_id": "c04_s02_cabinet_doors",
	},
	"c04_s02_cabinet_doors": {
		"id": "c04_s02_cabinet_doors",
		"chapter_id": "04_cabinet_breath",
		"title": "柜门开合",
		"phase": "entry",
		"narrative": "每关一次门，外面就闷一点；每开一次，雨声就近一点。",
		"background_key": "bg_c04_cabinet_doors",
		"interaction_type": "repeat_toggle",
		"interaction": {
			"gesture": "tap_then_hold",
			"target_id": "cabinet_door",
			"repeat_count": 3,
			"final_gesture": "hold",
		},
		"objective": "柜门开了又合。第三次，门缝后的雨声没有立刻散掉。",
		"hint": "关上时心跳变近，打开时雨声变近。第三次，手指没有离开柜门。",
		"completion_feedback": "雨点落到窗框上，小孩把膝盖缩进柜子。",
		"collectibles": [],
		"next_scene_id": "c04_s03_rain_classroom",
	},
	"c04_s03_rain_classroom": {
		"id": "c04_s03_rain_classroom",
		"chapter_id": "04_cabinet_breath",
		"title": "老教室雨声",
		"phase": "inner_world",
		"narrative": "老教室潮湿发暗。三种声音在空课桌之间来回找位置。",
		"background_key": "bg_c04_rain_classroom",
		"interaction_type": "slot_placement",
		"interaction": {
			"gesture": "drag",
			"assignments": {
				"rain": "window",
				"steps": "door",
				"breath": "bag",
			},
		},
		"objective": "雨声贴着窗，脚步停在门外，呼吸缩进书包的褶皱里。",
		"hint": "窗边有雨，门外有脚步；书包里，只装得下一口呼吸。",
		"completion_feedback": "雨落在窗上，脚步停在门外；书包里只剩贴近耳朵的呼吸。",
		"collectibles": [],
		"next_scene_id": "c04_s04_cabinet_islands",
	},
	"c04_s04_cabinet_islands": {
		"id": "c04_s04_cabinet_islands",
		"chapter_id": "04_cabinet_breath",
		"title": "储物柜群岛",
		"phase": "inner_world",
		"narrative": "三个柜门一字排开：课本、树叶，还有一格空空的黑。",
		"background_key": "bg_c04_cabinet_islands",
		"interaction_type": "compare_spaces",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["book_cabinet", "leaf_cabinet", "empty_cabinet"],
			"required_count": 3,
			"finish_target_id": "forest_shadow_door",
		},
		"objective": "课本柜、树叶柜、空柜，各自留着不同的回声和宽窄。",
		"hint": "空处的回声太远。肩膀碰到边的地方，心跳反而稳一点。",
		"completion_feedback": "三个柜子的近声叠在一起，树影从门里探进走廊。",
		"collectibles": ["plastic_ruler"],
		"next_scene_id": "c04_s05_forest_edge_hide",
	},
	"c04_s05_forest_edge_hide": {
		"id": "c04_s05_forest_edge_hide",
		"chapter_id": "04_cabinet_breath",
		"title": "山林边缘躲猫猫",
		"phase": "inner_world",
		"narrative": "树影伏在门缝外。胸口跳得很响，柜壁却稳稳贴着肩膀。",
		"background_key": "bg_c04_forest_edge_hide",
		"interaction_type": "posture_sequence",
		"interaction": {
			"gesture": "ordered_gestures",
			"required_order": ["drag_inside", "set_narrow_gap", "hold_breath_slow"],
			"hold_seconds": 3.0,
		},
		"objective": "身体缩进黑暗，门缝只剩一线光；呼吸一拍一拍追上来。",
		"hint": "门缝只剩一指宽，柜壁贴着肩膀；心跳数到第三下。",
		"completion_feedback": "门外脚步走远，柜壁里只剩三下平稳的呼吸。",
		"collectibles": [],
		"next_scene_id": "c04_s06_quiet_room_echo",
	},
	"c04_s06_quiet_room_echo": {
		"id": "c04_s06_quiet_room_echo",
		"chapter_id": "04_cabinet_breath",
		"title": "安静房间",
		"phase": "echo",
		"narrative": "灯暗一点，手机翻过去；这十分钟里不必发生什么大事。",
		"background_key": "bg_c04_quiet_room_echo",
		"interaction_type": "echo_revisit",
		"interaction": {
			"gesture": "tap_then_hold",
			"target_ids": ["phone", "lamp", "plastic_ruler"],
			"required_count": 2,
			"finish_target_id": "chair",
			"hold_seconds": 3.0,
		},
		"objective": "手机屏幕还亮着，顶灯也白着；椅背留着三秒钟的空位。",
		"hint": "消息没有消失，只是晚一点再响。",
		"completion_feedback": "手机没有再响。房间收住了这一小段安静。",
		"collectibles": [],
		"next_scene_id": "",
	},

	# Chapter 5: 密林之后
	"c05_s01_forest_edge": {
		"id": "c05_s01_forest_edge",
		"chapter_id": "05_after_forest",
		"title": "旧校林边",
		"phase": "opening",
		"narrative": "树影让出一条缝。他的鞋尖已经踩进潮泥。",
		"background_key": "bg_c05_forest_edge",
		"interaction_type": "hotspot_sequence",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["old_school", "forest_shadow", "mud"],
			"required_count": 3,
			"finish_target_id": "forest_path",
		},
		"objective": "旧校、树影和潮泥，都留着一点没走完的方向。",
		"hint": "树影让出一条缝，泥上还没有脚印。",
		"completion_feedback": "潮泥留下脚印，树叶把路往深处递了一点。",
		"collectibles": [],
		"next_scene_id": "c05_s02_tree_shadow_path",
	},
	"c05_s02_tree_shadow_path": {
		"id": "c05_s02_tree_shadow_path",
		"chapter_id": "05_after_forest",
		"title": "树影小路",
		"phase": "entry",
		"narrative": "每往前一点，光就从别的地方漏进来，左右手的小人也在地上醒了一下。",
		"background_key": "bg_c05_tree_shadow_path",
		"interaction_type": "multi_touch_sequence",
		"interaction": {
			"gesture": "ordered_gestures",
			"required_order": ["drag_branch", "tap_shadow", "hold_two_fingers"],
			"touch_points": 2,
		},
		"objective": "低枝挡在前面，地上的手影却先动了；两根手指靠近时，它们才站稳。",
		"hint": "枝叶后面有光。光里要有两个小人。",
		"completion_feedback": "两个手影先互相推了一下，树影随后连成通往地下的路。",
		"collectibles": [],
		"next_scene_id": "c05_s03_underground_classroom",
	},
	"c05_s03_underground_classroom": {
		"id": "c05_s03_underground_classroom",
		"chapter_id": "05_after_forest",
		"title": "地下教室",
		"phase": "inner_world",
		"narrative": "黑板、车窗、漫画页和柜门在这里重新会合，不讲道理，却异常自然。",
		"background_key": "bg_c05_underground_classroom",
		"interaction_type": "collect_clues",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["blackboard", "window", "manga_page", "cabinet"],
			"required_count": 3,
			"finish_target_id": "fossil_table",
		},
		"objective": "四样旧东西里，有三道细光正往泥台聚拢。",
		"hint": "粉笔、车灯、纸边和雨声，都在这里留了一小点。",
		"completion_feedback": "旧物各自让出一条缝，透明盒在靠里的泥台上亮起来。",
		"collectibles": ["glass_marble"],
		"next_scene_id": "c05_s04_impossible_fossil",
	},
	"c05_s04_impossible_fossil": {
		"id": "c05_s04_impossible_fossil",
		"chapter_id": "05_after_forest",
		"title": "不可能的化石",
		"phase": "inner_world",
		"narrative": "现实里没有成功过的愿望，安静地躺在沾着干土的透明盒里。",
		"background_key": "bg_c05_impossible_fossil",
		"interaction_type": "collect_clues",
		"interaction": {
			"gesture": "tap",
			"target_ids": ["fossil_box", "why_book", "old_mud"],
			"required_count": 3,
			"finish_target_id": "fossil_box",
		},
		"objective": "透明盒、科普书和干泥，拼着一件没有成功过的小事。",
		"hint": "图很好看；甲虫埋进土里，等了很久。",
		"completion_feedback": "不像真的，但它在这里。两个争执的手影一起护住盒子。",
		"collectibles": ["impossible_fossil"],
		"next_scene_id": "c05_s05_finger_stage",
	},
	"c05_s05_finger_stage": {
		"id": "c05_s05_finger_stage",
		"chapter_id": "05_after_forest",
		"title": "手指小人舞台",
		"phase": "inner_world",
		"narrative": "两个手影还在墙上推搡，谁也不肯让开那只盒子。",
		"background_key": "bg_c05_finger_stage",
		"interaction_type": "multi_touch_sequence",
		"interaction": {
			"gesture": "two_finger_sequence",
			"required_order": ["separate", "lift", "hold"],
			"touch_points": 2,
		},
		"objective": "两个手影分立墙角，共同抬起木板，最后合拢在盒子上方。",
		"hint": "一只手影托不平木板；第二道影子压住了翘起的另一头。",
		"completion_feedback": "黑板排开，车灯成路，课桌挪出空隙，柜门通向普通晨光。",
		"collectibles": [],
		"next_scene_id": "c05_s06_morning_echo",
	},
	"c05_s06_morning_echo": {
		"id": "c05_s06_morning_echo",
		"chapter_id": "05_after_forest",
		"title": "普通晨光",
		"phase": "echo",
		"narrative": "晨光照进房间。桌上的小东西没有消失，窗外的树也还在。",
		"background_key": "bg_c05_morning_echo",
		"interaction_type": "echo_revisit",
		"interaction": {
			"gesture": "tap_drag_then_send",
			"target_ids": ["new_pen", "fossil", "marble", "window"],
			"required_count": 3,
			"required_actions": ["arrange_items", "send_friend_message"],
		},
		"objective": "喜欢的笔、玻璃弹珠和化石盒换了位置；窗外还有一个很久没问候的人。",
		"hint": "通讯录里，那个名字仍在原处。",
		"completion_feedback": "前面还有啥呢？",
		"collectibles": [],
		"next_scene_id": "",
	},
}

const REQUIRED_SCENE_KEYS := [
	"id",
	"chapter_id",
	"title",
	"phase",
	"narrative",
	"background_key",
	"interaction_type",
	"interaction",
	"objective",
	"hint",
	"completion_feedback",
	"collectibles",
	"next_scene_id",
]


static func get_chapter_ids() -> PackedStringArray:
	return PackedStringArray(CHAPTER_ORDER)


static func has_chapter(chapter_id: StringName) -> bool:
	return CHAPTERS.has(String(chapter_id))


static func get_chapter(chapter_id: StringName) -> Dictionary:
	var chapter: Dictionary = CHAPTERS.get(String(chapter_id), {})
	return chapter.duplicate(true)


static func get_scene_ids(chapter_id: StringName = &"") -> PackedStringArray:
	if chapter_id == &"":
		var all_ids := PackedStringArray()
		for ordered_chapter_id in CHAPTER_ORDER:
			var chapter: Dictionary = CHAPTERS[ordered_chapter_id]
			all_ids.append_array(PackedStringArray(chapter["scene_ids"]))
		return all_ids
	var chapter: Dictionary = CHAPTERS.get(String(chapter_id), {})
	return PackedStringArray(chapter.get("scene_ids", []))


static func has_scene(scene_id: StringName) -> bool:
	return SCENES.has(String(scene_id))


static func get_scene(scene_id: StringName) -> Dictionary:
	var scene: Dictionary = SCENES.get(String(scene_id), {})
	return scene.duplicate(true)


static func get_scenes_for_chapter(chapter_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for scene_id in get_scene_ids(chapter_id):
		result.append(get_scene(scene_id))
	return result


static func get_first_scene_id(chapter_id: StringName) -> String:
	var scene_ids := get_scene_ids(chapter_id)
	return "" if scene_ids.is_empty() else scene_ids[0]


static func get_next_scene_id(scene_id: StringName) -> String:
	var scene: Dictionary = SCENES.get(String(scene_id), {})
	return String(scene.get("next_scene_id", ""))


static func get_collectible(collectible_id: StringName) -> Dictionary:
	var collectible: Dictionary = COLLECTIBLES.get(String(collectible_id), {})
	return collectible.duplicate(true)


## Returns an empty PackedStringArray when the catalog is internally consistent.
## It checks the 5 x 6 shape, required fields, enums, chapter ownership,
## collectible references and each chapter's exact next-scene chain.
static func validate_catalog() -> PackedStringArray:
	var errors := PackedStringArray()
	var referenced_scene_ids := {}
	var referenced_collectibles := {}

	if CHAPTER_ORDER.size() != 5:
		errors.append("Expected 5 chapters, found %d." % CHAPTER_ORDER.size())
	if CHAPTERS.size() != CHAPTER_ORDER.size():
		errors.append("CHAPTERS count does not match CHAPTER_ORDER.")
	if SCENES.size() != 30:
		errors.append("Expected 30 scenes, found %d." % SCENES.size())

	for chapter_index in CHAPTER_ORDER.size():
		var chapter_id: String = CHAPTER_ORDER[chapter_index]
		if not CHAPTERS.has(chapter_id):
			errors.append("Missing chapter: %s." % chapter_id)
			continue
		var chapter: Dictionary = CHAPTERS[chapter_id]
		if String(chapter.get("id", "")) != chapter_id:
			errors.append("Chapter key/id mismatch: %s." % chapter_id)
		if int(chapter.get("number", -1)) != chapter_index + 1:
			errors.append("Unexpected chapter number for %s." % chapter_id)
		if String(chapter.get("title", "")).is_empty():
			errors.append("Chapter %s has an empty title." % chapter_id)
		if String(chapter.get("theme", "")).is_empty():
			errors.append("Chapter %s has an empty theme." % chapter_id)
		if not chapter.get("completion", {}) is Dictionary:
			errors.append("Chapter %s completion must be a Dictionary." % chapter_id)
		var scene_ids: Array = chapter.get("scene_ids", [])
		if scene_ids.size() != 6:
			errors.append("Chapter %s must contain 6 scenes, found %d." % [chapter_id, scene_ids.size()])

		for scene_index in scene_ids.size():
			var scene_id := String(scene_ids[scene_index])
			if referenced_scene_ids.has(scene_id):
				errors.append("Scene referenced more than once: %s." % scene_id)
			referenced_scene_ids[scene_id] = true
			if not SCENES.has(scene_id):
				errors.append("Missing scene: %s." % scene_id)
				continue
			var scene: Dictionary = SCENES[scene_id]
			for required_key in REQUIRED_SCENE_KEYS:
				if not scene.has(required_key):
					errors.append("Scene %s missing key: %s." % [scene_id, required_key])
			if String(scene.get("id", "")) != scene_id:
				errors.append("Scene key/id mismatch: %s." % scene_id)
			if String(scene.get("chapter_id", "")) != chapter_id:
				errors.append("Scene %s has wrong chapter_id." % scene_id)
			if not VALID_PHASES.has(String(scene.get("phase", ""))):
				errors.append("Scene %s has invalid phase." % scene_id)
			var expected_phase := "inner_world"
			if scene_index == 0:
				expected_phase = "opening"
			elif scene_index == 1:
				expected_phase = "entry"
			elif scene_index == scene_ids.size() - 1:
				expected_phase = "echo"
			if String(scene.get("phase", "")) != expected_phase:
				errors.append("Scene %s has unexpected phase for its chapter position." % scene_id)
			if not VALID_INTERACTION_TYPES.has(String(scene.get("interaction_type", ""))):
				errors.append("Scene %s has invalid interaction_type." % scene_id)
			if not scene.get("interaction", {}) is Dictionary:
				errors.append("Scene %s interaction must be a Dictionary." % scene_id)
			elif scene.get("interaction", {}).is_empty():
				errors.append("Scene %s interaction cannot be empty." % scene_id)
			for text_key in ["title", "narrative", "objective", "hint", "completion_feedback"]:
				if String(scene.get(text_key, "")).is_empty():
					errors.append("Scene %s has empty text: %s." % [scene_id, text_key])
			if String(scene.get("background_key", "")).is_empty():
				errors.append("Scene %s has an empty background_key." % scene_id)
			if not scene.get("collectibles", []) is Array:
				errors.append("Scene %s collectibles must be an Array." % scene_id)

			var expected_next := ""
			if scene_index + 1 < scene_ids.size():
				expected_next = String(scene_ids[scene_index + 1])
			if String(scene.get("next_scene_id", "")) != expected_next:
				errors.append("Scene %s has an invalid next_scene_id." % scene_id)

			var scene_collectibles: Array = scene.get("collectibles", [])
			for collectible_id_value in scene_collectibles:
				var collectible_id := String(collectible_id_value)
				if not COLLECTIBLES.has(collectible_id):
					errors.append("Scene %s references unknown collectible %s." % [scene_id, collectible_id])
				elif String(COLLECTIBLES[collectible_id].get("chapter_id", "")) != chapter_id:
					errors.append("Collectible %s is assigned to the wrong chapter." % collectible_id)
				if referenced_collectibles.has(collectible_id):
					errors.append("Collectible has more than one acquisition scene: %s." % collectible_id)
				referenced_collectibles[collectible_id] = true

	for scene_id_value in SCENES:
		var scene_id := String(scene_id_value)
		if not referenced_scene_ids.has(scene_id):
			errors.append("Scene is not listed by a chapter: %s." % scene_id)
	for collectible_id_value in COLLECTIBLES:
		var collectible_id := String(collectible_id_value)
		if not referenced_collectibles.has(collectible_id):
			errors.append("Collectible has no acquisition scene: %s." % collectible_id)

	return errors
