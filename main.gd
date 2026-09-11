extends Node2D

# ============================================================
# AADU PULI AATTAM - GOATS AND TIGERS
# VERSION 1
# Complete playable version with:
# - Goat placement and movement
# - Tiger movement and capture
# - Win conditions
# - Instructions screen
# - Game over screen
# - Restart / Play Again
# - Improved visual feedback
# ============================================================


# ============================================================
# GAME CONSTANTS
# ============================================================

const EMPTY = 0
const GOAT = 1
const TIGER = 2

const GOAT_TURN = 0
const TIGER_TURN = 1

const POINT_RADIUS = 18.0
const CLICK_RADIUS = 42.0


# ============================================================
# GAME VARIABLES
# ============================================================

var board = []

var current_turn = GOAT_TURN

var goats_to_place = 15
var goats_captured = 0

var selected_position = -1

var game_over = false
var winner_text = ""
var winner_subtitle = ""

var show_instructions = false


# ============================================================
# BOARD POSITIONS
# ============================================================

var positions = [

	Vector2(500, 75),

	Vector2(410, 145),
	Vector2(590, 145),

	Vector2(330, 215),
	Vector2(415, 215),
	Vector2(500, 215),
	Vector2(585, 215),
	Vector2(670, 215),

	Vector2(285, 300),
	Vector2(355, 300),
	Vector2(430, 300),
	Vector2(570, 300),
	Vector2(645, 300),
	Vector2(715, 300),

	Vector2(330, 390),
	Vector2(415, 390),
	Vector2(500, 390),
	Vector2(585, 390),
	Vector2(670, 390),

	Vector2(410, 475),
	Vector2(500, 475),
	Vector2(590, 475),

	Vector2(500, 550)
]


# ============================================================
# BOARD CONNECTIONS
# ============================================================

var connections = [

	[1, 2],

	[0, 2, 3, 4],

	[0, 1, 4, 5],

	[1, 4, 8, 9],

	[1, 2, 3, 5, 9, 10],

	[2, 4, 6, 10, 11],

	[2, 5, 7, 11, 12],

	[2, 6, 12, 13],

	[3, 9, 14],

	[3, 4, 8, 10, 14, 15],

	[4, 5, 9, 11, 15, 16],

	[5, 6, 10, 12, 16, 17],

	[6, 7, 11, 13, 17, 18],

	[7, 12, 18],

	[8, 9, 15, 19],

	[9, 10, 14, 16, 19, 20],

	[10, 11, 15, 17, 20, 21],

	[11, 12, 16, 18, 21, 22],

	[12, 13, 17],

	[14, 15, 20],

	[15, 16, 19, 21, 22],

	[16, 17, 20, 22],

	[17, 20, 21]
]


# ============================================================
# START GAME
# ============================================================

func _ready():

	DisplayServer.window_set_size(Vector2i(1000, 650))

	start_new_game()


# ============================================================
# START / RESTART GAME
# ============================================================

func start_new_game():

	board.clear()

	for i in range(23):

		board.append(EMPTY)


	# Three tigers start at the top

	board[0] = TIGER
	board[1] = TIGER
	board[2] = TIGER


	current_turn = GOAT_TURN

	goats_to_place = 15
	goats_captured = 0

	selected_position = -1

	game_over = false

	winner_text = ""
	winner_subtitle = ""

	show_instructions = false

	queue_redraw()


# ============================================================
# DRAW EVERYTHING
# ============================================================

func _draw():

	var font = ThemeDB.fallback_font


	# ========================================================
	# BACKGROUND
	# ========================================================

	draw_rect(
		Rect2(0, 0, 1000, 650),
		Color("#F3E5C8")
	)


	# ========================================================
	# TITLE
	# ========================================================

	draw_string(
		font,
		Vector2(350, 32),
		"AADU PULI AATTAM",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		27,
		Color("#4A2C20")
	)

	draw_string(
		font,
		Vector2(405, 55),
		"GOATS & TIGERS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color("#7A5545")
	)


	# ========================================================
	# INSTRUCTIONS BUTTON
	# ========================================================

	draw_rect(
		Rect2(680, 20, 140, 38),
		Color("#8B5E3C")
	)

	draw_string(
		font,
		Vector2(705, 45),
		"HOW TO PLAY",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		13,
		Color.WHITE
	)


	# ========================================================
	# RESTART BUTTON
	# ========================================================

	draw_rect(
		Rect2(835, 20, 125, 38),
		Color("#6B4636")
	)

	draw_string(
		font,
		Vector2(862, 45),
		"RESTART",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color.WHITE
	)


	# ========================================================
	# BOARD CONNECTIONS
	# ========================================================

	for i in range(positions.size()):

		for connected in connections[i]:

			if connected > i:

				draw_line(
					positions[i],
					positions[connected],
					Color("#6B4636"),
					4.0
				)


	# ========================================================
	# BOARD POINTS
	# ========================================================

	for i in range(positions.size()):

		draw_circle(
			positions[i],
			POINT_RADIUS,
			Color("#D4A373")
		)

		draw_circle(
			positions[i],
			POINT_RADIUS,
			Color("#4A2C20"),
			false,
			2.5
		)


	# ========================================================
	# PIECES
	# ========================================================

	for i in range(board.size()):

		if board[i] == GOAT:

			draw_goat(positions[i])

		elif board[i] == TIGER:

			draw_tiger(positions[i])


	# ========================================================
	# SELECTED PIECE
	# ========================================================

	if selected_position != -1 and not game_over:

		draw_circle(
			positions[selected_position],
			POINT_RADIUS + 8,
			Color("#FFD54F"),
			false,
			4.0
		)


	# ========================================================
	# BOTTOM INFORMATION PANEL
	# ========================================================

	draw_rect(
		Rect2(20, 580, 960, 55),
		Color("#4A2C20")
	)


	# ========================================================
	# TURN DISPLAY
	# ========================================================

	var turn_text = ""

	if game_over:

		turn_text = winner_text

	elif current_turn == GOAT_TURN:

		if goats_to_place > 0:

			turn_text = "🐐 GOATS TURN - PLACE A GOAT"

		else:

			turn_text = "🐐 GOATS TURN - MOVE A GOAT"

	else:

		turn_text = "🐯 TIGERS TURN"


	draw_string(
		font,
		Vector2(40, 614),
		turn_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)


	# ========================================================
	# GOATS TO PLACE
	# ========================================================

	draw_string(
		font,
		Vector2(450, 614),
		"Goats to place: " + str(goats_to_place),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)


	# ========================================================
	# CAPTURE COUNTER
	# ========================================================

	draw_string(
		font,
		Vector2(750, 614),
		"Captured: " + str(goats_captured) + " / 5",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)


	# ========================================================
	# INSTRUCTIONS WINDOW
	# ========================================================

	if show_instructions:

		draw_instructions(font)


	# ========================================================
	# GAME OVER WINDOW
	# ========================================================

	if game_over:

		draw_game_over(font)


# ============================================================
# DRAW GOAT
# ============================================================

func draw_goat(pos: Vector2):

	draw_circle(
		pos,
		16,
		Color("#F5F5F5")
	)

	draw_circle(
		pos,
		16,
		Color("#5D4037"),
		false,
		2.5
	)

	var font = ThemeDB.fallback_font

	draw_string(
		font,
		pos + Vector2(-6, 6),
		"G",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		17,
		Color("#5D4037")
	)


# ============================================================
# DRAW TIGER
# ============================================================

func draw_tiger(pos: Vector2):

	draw_circle(
		pos,
		17,
		Color("#E88B32")
	)

	draw_circle(
		pos,
		17,
		Color("#4A2C20"),
		false,
		2.5
	)

	var font = ThemeDB.fallback_font

	draw_string(
		font,
		pos + Vector2(-6, 6),
		"T",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		17,
		Color("#4A2C20")
	)


# ============================================================
# INSTRUCTIONS WINDOW
# ============================================================

func draw_instructions(font):

	# Dark overlay

	draw_rect(
		Rect2(0, 0, 1000, 650),
		Color(0, 0, 0, 0.35)
	)


	# Main panel

	draw_rect(
		Rect2(180, 75, 640, 500),
		Color("#FFF8E7")
	)

	draw_rect(
		Rect2(180, 75, 640, 500),
		Color("#4A2C20"),
		false,
		4.0
	)


	# Title

	draw_string(
		font,
		Vector2(390, 120),
		"HOW TO PLAY",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		27,
		Color("#4A2C20")
	)


	# Goats heading

	draw_string(
		font,
		Vector2(235, 165),
		"GOATS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		21,
		Color("#5D4037")
	)


	draw_string(
		font,
		Vector2(235, 195),
		"1. Place 15 goats on empty board points.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	draw_string(
		font,
		Vector2(235, 225),
		"2. After placing all goats, move them",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	draw_string(
		font,
		Vector2(255, 250),
		"along connected lines.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	draw_string(
		font,
		Vector2(235, 280),
		"3. Block all three tigers to win.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	# Tigers heading

	draw_string(
		font,
		Vector2(235, 325),
		"TIGERS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		21,
		Color("#E07820")
	)


	draw_string(
		font,
		Vector2(235, 355),
		"1. Select a tiger and move along a line.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	draw_string(
		font,
		Vector2(235, 385),
		"2. Jump over a goat to capture it.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	draw_string(
		font,
		Vector2(235, 415),
		"3. Capture 5 goats to win.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	# Controls

	draw_string(
		font,
		Vector2(235, 455),
		"Click a piece to select it.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		Color("#7A5545")
	)

	draw_string(
		font,
		Vector2(235, 480),
		"Click a connected empty point to move.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		Color("#7A5545")
	)


	# Close button

	draw_rect(
		Rect2(430, 510, 140, 42),
		Color("#6B4636")
	)

	draw_string(
		font,
		Vector2(468, 537),
		"CLOSE",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		Color.WHITE
	)


# ============================================================
# GAME OVER WINDOW
# ============================================================

func draw_game_over(font):

	# Dark overlay

	draw_rect(
		Rect2(0, 0, 1000, 650),
		Color(0, 0, 0, 0.42)
	)


	# Main game-over panel

	draw_rect(
		Rect2(235, 180, 530, 300),
		Color("#FFF8E7")
	)

	draw_rect(
		Rect2(235, 180, 530, 300),
		Color("#4A2C20"),
		false,
		5.0
	)


	# Winner title

	draw_string(
		font,
		Vector2(365, 245),
		winner_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		27,
		Color("#4A2C20")
	)


	# Subtitle

	draw_string(
		font,
		Vector2(370, 285),
		winner_subtitle,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		Color("#7A5545")
	)


	# Final score

	draw_string(
		font,
		Vector2(375, 325),
		"Goats captured: " + str(goats_captured) + " / 5",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("#4A2C20")
	)


	# Play Again button

	draw_rect(
		Rect2(370, 370, 260, 55),
		Color("#6B4636")
	)

	draw_string(
		font,
		Vector2(433, 405),
		"PLAY AGAIN",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		20,
		Color.WHITE
	)


# ============================================================
# MOUSE INPUT
# ============================================================

func _input(event):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var mouse_position = get_global_mouse_position()


			# ==================================================
			# GAME OVER - PLAY AGAIN
			# ==================================================

			if game_over:

				if Rect2(370, 370, 260, 55).has_point(mouse_position):

					start_new_game()

				return


			# ==================================================
			# INSTRUCTIONS
			# ==================================================

			if show_instructions:

				if Rect2(430, 510, 140, 42).has_point(mouse_position):

					show_instructions = false

					queue_redraw()

				return


			# ==================================================
			# HOW TO PLAY BUTTON
			# ==================================================

			if Rect2(680, 20, 140, 38).has_point(mouse_position):

				show_instructions = true

				selected_position = -1

				queue_redraw()

				return


			# ==================================================
			# RESTART BUTTON
			# ==================================================

			if Rect2(835, 20, 125, 38).has_point(mouse_position):

				start_new_game()

				return


			# ==================================================
			# BOARD
			# ==================================================

			var clicked = find_board_position(mouse_position)

			if clicked != -1:

				handle_click(clicked)


# ============================================================
# FIND BOARD POSITION
# ============================================================

func find_board_position(mouse_position: Vector2) -> int:

	for i in range(positions.size()):

		var distance = positions[i].distance_to(mouse_position)

		if distance <= CLICK_RADIUS:

			return i

	return -1


# ============================================================
# HANDLE CLICK
# ============================================================

func handle_click(position: int):

	if game_over:

		return


	# ========================================================
	# GOAT PLACEMENT
	# ========================================================

	if current_turn == GOAT_TURN and goats_to_place > 0:

		if board[position] == EMPTY:

			board[position] = GOAT

			goats_to_place -= 1

			selected_position = -1


			# Check goat victory

			if all_tigers_blocked():

				game_over = true

				winner_text = "GOATS WIN!"

				winner_subtitle = "TIGERS ARE BLOCKED"

				queue_redraw()

				return


			current_turn = TIGER_TURN

			queue_redraw()

		return


	# ========================================================
	# SELECT PIECE
	# ========================================================

	if selected_position == -1:

		if current_turn == GOAT_TURN:

			if board[position] == GOAT:

				selected_position = position

		elif current_turn == TIGER_TURN:

			if board[position] == TIGER:

				selected_position = position

		queue_redraw()

		return


	# ========================================================
	# DESELECT
	# ========================================================

	if selected_position == position:

		selected_position = -1

		queue_redraw()

		return


	# ========================================================
	# MOVE
	# ========================================================

	try_move(selected_position, position)


# ============================================================
# TRY MOVE
# ============================================================

func try_move(from: int, to: int):


	# ========================================================
	# DESTINATION NOT EMPTY
	# ========================================================

	if board[to] != EMPTY:

		if current_turn == GOAT_TURN:

			if board[to] == GOAT:

				selected_position = to

				queue_redraw()

		elif current_turn == TIGER_TURN:

			if board[to] == TIGER:

				selected_position = to

				queue_redraw()

		return


	# ========================================================
	# GOAT MOVEMENT
	# ========================================================

	if current_turn == GOAT_TURN:

		if goats_to_place > 0:

			selected_position = -1

			queue_redraw()

			return


		if to in connections[from]:

			board[to] = GOAT

			board[from] = EMPTY

			selected_position = -1

			current_turn = TIGER_TURN

			queue_redraw()

		return


	# ========================================================
	# TIGER MOVEMENT
	# ========================================================

	if current_turn == TIGER_TURN:


		# ----------------------------------------------------
		# CAPTURE
		# ----------------------------------------------------

		var capture_point = get_capture_goat(from, to)

		if capture_point != -1:

			board[to] = TIGER

			board[from] = EMPTY

			board[capture_point] = EMPTY

			goats_captured += 1

			selected_position = -1


			# Tiger wins

			if goats_captured >= 5:

				game_over = true

				winner_text = "TIGERS WIN!"

				winner_subtitle = "5 GOATS CAPTURED"

				queue_redraw()

				return


			current_turn = GOAT_TURN

			queue_redraw()

			return


		# ----------------------------------------------------
		# NORMAL MOVE
		# ----------------------------------------------------

		if to in connections[from]:

			board[to] = TIGER

			board[from] = EMPTY

			selected_position = -1

			current_turn = GOAT_TURN


			# Check goat victory

			if all_tigers_blocked():

				game_over = true

				winner_text = "GOATS WIN!"

				winner_subtitle = "TIGERS ARE BLOCKED"


			queue_redraw()

			return


	# ========================================================
	# INVALID MOVE
	# ========================================================

	selected_position = -1

	queue_redraw()


# ============================================================
# TIGER CAPTURE CHECK
# ============================================================

func get_capture_goat(from: int, landing: int) -> int:

	if board[landing] != EMPTY:

		return -1


	for middle in connections[from]:

		if board[middle] != GOAT:

			continue


		if landing not in connections[middle]:

			continue


		if are_collinear_jump(from, middle, landing):

			return middle


	return -1


# ============================================================
# CHECK STRAIGHT-LINE JUMP
# ============================================================

func are_collinear_jump(
	from: int,
	middle: int,
	landing: int
) -> bool:

	var first_vector = positions[middle] - positions[from]

	var second_vector = positions[landing] - positions[middle]


	var cross_product = (
		first_vector.x * second_vector.y
		- first_vector.y * second_vector.x
	)


	if abs(cross_product) > 1.0:

		return false


	var first_length = first_vector.length()

	var second_length = second_vector.length()


	if abs(first_length - second_length) > 5.0:

		return false


	return true


# ============================================================
# CHECK IF ALL TIGERS ARE BLOCKED
# ============================================================

func all_tigers_blocked() -> bool:

	for i in range(board.size()):

		if board[i] != TIGER:

			continue


		# Normal moves

		for neighbour in connections[i]:

			if board[neighbour] == EMPTY:

				return false


		# Capture moves

		for middle in connections[i]:

			if board[middle] != GOAT:

				continue


			for landing in connections[middle]:

				if board[landing] != EMPTY:

					continue


				if are_collinear_jump(i, middle, landing):

					return false


	return true
