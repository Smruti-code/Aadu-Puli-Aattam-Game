extends Node2D

# ============================================================
# AADU PULI AATTAM - VERSION 2
# Human vs Tiger Strategist Edition
# ============================================================

# -----------------------------
# GAME CONSTANTS
# -----------------------------

const EMPTY = 0
const GOAT = 1
const TIGER = 2

const GOAT_TURN = 0
const TIGER_TURN = 1

const TOTAL_GOATS = 15
const TIGER_WIN_CAPTURES = 5

const POINT_RADIUS = 20.0
const CLICK_RADIUS = 43.0

const BOARD_WIDTH = 1000.0
const BOARD_HEIGHT = 700.0

# -----------------------------
# BOARD
# -----------------------------

var points = [
	Vector2(500, 100),
	Vector2(410, 165),
	Vector2(590, 165),

	Vector2(330, 230),
	Vector2(415, 230),
	Vector2(500, 230),
	Vector2(585, 230),
	Vector2(670, 230),

	Vector2(285, 315),
	Vector2(355, 315),
	Vector2(430, 315),
	Vector2(570, 315),
	Vector2(645, 315),
	Vector2(715, 315),

	Vector2(330, 405),
	Vector2(415, 405),
	Vector2(500, 405),
	Vector2(585, 405),
	Vector2(670, 405),

	Vector2(410, 490),
	Vector2(500, 490),
	Vector2(590, 490),

	Vector2(500, 565)
]

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

# -----------------------------
# GAME STATE
# -----------------------------

var board = []

var current_turn = GOAT_TURN

var goats_to_place = TOTAL_GOATS
var captured_goats = 0

var selected_piece = -1
var legal_targets = []

var game_over = false
var show_instructions = false

var winner_text = ""
var winner_subtitle = ""

var ai_thinking = false
var ai_timer = 0.0

var status_message = "Place your goats on the board."

var move_number = 1

# -----------------------------
# VISUAL ANIMATION
# -----------------------------

var pulse_time = 0.0

var moving_piece = -1
var moving_from = Vector2.ZERO
var moving_to = Vector2.ZERO
var moving_progress = 0.0

var capture_flash = 0.0
var invalid_flash = 0.0

var last_move_from = -1
var last_move_to = -1

# -----------------------------
# COLORS
# -----------------------------

var bg_color = Color("#101820")
var panel_color = Color("#182630")
var panel_light = Color("#223542")

var board_line_color = Color("#B9A77B")
var board_point_color = Color("#D8C59A")

var goat_color = Color("#F2E4C9")
var goat_outline = Color("#6D4C41")

var tiger_color = Color("#E79A32")
var tiger_outline = Color("#5A3015")

var accent_color = Color("#FFD54F")
var green_color = Color("#74D99A")
var red_color = Color("#F27777")
var blue_color = Color("#71B7FF")

var white_color = Color("#F5F5F5")
var muted_color = Color("#AAB8C2")

var font

# -----------------------------
# BUTTONS
# -----------------------------

var how_button = Rect2(660, 25, 135, 42)
var restart_button = Rect2(810, 25, 145, 42)

var close_button = Rect2(390, 585, 220, 50)
var play_again_button = Rect2(370, 440, 260, 55)

# ============================================================
# READY
# ============================================================

func _ready():
	font = ThemeDB.fallback_font

	start_new_game()

	queue_redraw()


# ============================================================
# NEW GAME
# ============================================================

func start_new_game():
	board.clear()

	for i in range(points.size()):
		board.append(EMPTY)

	# Three Tigers start at top
	board[0] = TIGER
	board[1] = TIGER
	board[2] = TIGER

	current_turn = GOAT_TURN

	goats_to_place = TOTAL_GOATS
	captured_goats = 0

	selected_piece = -1
	legal_targets.clear()

	game_over = false
	show_instructions = false

	winner_text = ""
	winner_subtitle = ""

	ai_thinking = false
	ai_timer = 0.0

	status_message = "Your turn: place a goat."

	move_number = 1

	moving_piece = -1
	moving_from = Vector2.ZERO
	moving_to = Vector2.ZERO
	moving_progress = 0.0

	capture_flash = 0.0
	invalid_flash = 0.0

	last_move_from = -1
	last_move_to = -1

	queue_redraw()


# ============================================================
# PROCESS
# ============================================================

func _process(delta):
	pulse_time += delta

	if capture_flash > 0:
		capture_flash -= delta

	if invalid_flash > 0:
		invalid_flash -= delta

	# Piece movement animation
	if moving_piece != -1:
		moving_progress += delta * 3.5

		if moving_progress >= 1.0:
			moving_progress = 1.0
			moving_piece = -1

		queue_redraw()

	# Tiger Strategist thinking
	if ai_thinking:
		ai_timer -= delta

		if ai_timer <= 0:
			ai_thinking = false
			perform_ai_turn()

	queue_redraw()


# ============================================================
# DRAW EVERYTHING
# ============================================================

func _draw():
	draw_background()
	draw_header()
	draw_board()
	draw_pieces()
	draw_selection()
	draw_bottom_panel()

	if ai_thinking:
		draw_ai_thinking()

	if show_instructions:
		draw_instructions()

	if game_over:
		draw_game_over()


# ============================================================
# BACKGROUND
# ============================================================

func draw_background():
	draw_rect(
		Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT),
		bg_color
	)

	# Decorative circles
	for i in range(8):
		var x = 80 + i * 125
		var y = 110 + sin(pulse_time * 0.3 + i) * 15

		draw_circle(
			Vector2(x, y),
			80,
			Color(0.12, 0.18, 0.22, 0.18)
		)

	# Main play area
	draw_rect(
		Rect2(40, 85, 920, 500),
		Color("#14212A")
	)

	draw_rect(
		Rect2(40, 85, 920, 500),
		Color("#263844"),
		false,
		2.0
	)


# ============================================================
# HEADER
# ============================================================

func draw_header():
	# Title
	draw_string(
		font,
		Vector2(40, 48),
		"AADU PULI AATTAM",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		30,
		accent_color
	)

	draw_string(
		font,
		Vector2(40, 72),
		"GOATS & TIGERS  •  VERSION 2",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		muted_color
	)

	# How to play
	draw_button(
		how_button,
		"HOW TO PLAY",
		blue_color
	)

	# Restart
	draw_button(
		restart_button,
		"RESTART",
		red_color
	)


# ============================================================
# BOARD
# ============================================================

func draw_board():
	# Draw connections
	for i in range(connections.size()):
		for j in connections[i]:
			if j > i:
				draw_line(
					points[i],
					points[j],
					board_line_color,
					3.0
				)

	# Draw board points
	for i in range(points.size()):
		var p = points[i]

		draw_circle(
			p,
			POINT_RADIUS + 5,
			Color("#0C1419")
		)

		draw_circle(
			p,
			POINT_RADIUS,
			board_point_color
		)

		draw_circle(
			p,
			POINT_RADIUS - 7,
			Color("#75664B")
		)


# ============================================================
# PIECES
# ============================================================

func draw_pieces():
	for i in range(board.size()):
		if board[i] == EMPTY:
			continue

		# If this piece is currently moving,
		# draw it at the animated location.
		if i == moving_piece:
			continue

		draw_piece(i, board[i], points[i])

	# Animated moving piece
	if moving_piece != -1:
		var pos = moving_from.lerp(
			moving_to,
			moving_progress
		)

		draw_piece(
			moving_piece,
			board[moving_piece],
			pos
		)


# ============================================================
# DRAW ONE PIECE
# ============================================================

func draw_piece(index, piece_type, pos):
	var is_goat = piece_type == GOAT

	var main_color = goat_color if is_goat else tiger_color
	var outline_color = goat_outline if is_goat else tiger_outline

	# Shadow
	draw_circle(
		pos + Vector2(3, 5),
		28,
		Color(0, 0, 0, 0.35)
	)

	# Outer ring
	draw_circle(
		pos,
		27,
		outline_color
	)

	# Main body
	draw_circle(
		pos,
		23,
		main_color
	)

	# Highlight
	draw_circle(
		pos + Vector2(-7, -7),
		7,
		Color(1, 1, 1, 0.35)
	)

	# Simple piece symbol
	if is_goat:
		draw_string(
			font,
			pos + Vector2(-8, 8),
			"G",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			19,
			goat_outline
		)
	else:
		draw_string(
			font,
			pos + Vector2(-9, 8),
			"T",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			19,
			tiger_outline
		)


# ============================================================
# SELECTION
# ============================================================

func draw_selection():
	if selected_piece == -1:
		return

	if selected_piece >= points.size():
		return

	var p = points[selected_piece]

	var radius = 34.0 + sin(pulse_time * 5.0) * 4.0

	draw_arc(
		p,
		radius,
		0,
		TAU,
		48,
		accent_color,
		4.0
	)

	# Legal target highlights
	for target in legal_targets:
		var target_pos = points[target]

		draw_circle(
			target_pos,
			30,
			Color(0.35, 1.0, 0.55, 0.22)
		)

		draw_arc(
			target_pos,
			31,
			0,
			TAU,
			32,
			green_color,
			3.0
		)


# ============================================================
# BOTTOM STATUS PANEL
# ============================================================

func draw_bottom_panel():
	# Increased height and moved upward so every line
	# remains completely visible inside the 700px window.
	var panel = Rect2(40, 575, 920, 105)

	draw_rect(
		panel,
		panel_color
	)

	draw_rect(
		panel,
		Color("#334957"),
		false,
		2.0
	)

	# Turn
	var turn_text = ""
	var turn_color = white_color

	if current_turn == GOAT_TURN:
		turn_text = "YOUR TURN"
		turn_color = green_color
	else:
		turn_text = "TIGERS TURN"
		turn_color = tiger_color

	draw_string(
		font,
		Vector2(60, 605),
		turn_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		20,
		turn_color
	)

	# Goat placement
	draw_string(
		font,
		Vector2(250, 605),
		"Goats to place: " + str(goats_to_place),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		white_color
	)

	# Captured
	draw_string(
		font,
		Vector2(470, 605),
		"Captured: " + str(captured_goats) + "/" + str(TIGER_WIN_CAPTURES),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		white_color
	)

	# Move number
	draw_string(
		font,
		Vector2(700, 605),
		"Move: " + str(move_number),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		muted_color
	)

	# Message
	draw_string(
		font,
		Vector2(60, 650),
		status_message,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		muted_color
	)


# ============================================================
# TIGER STRATEGIST THINKING
# ============================================================

func draw_ai_thinking():
	var box = Rect2(340, 300, 320, 70)

	draw_rect(
		box,
		Color("#182A35")
	)

	draw_rect(
		box,
		tiger_color,
		false,
		3.0
	)

	var dots = ""
	var phase = int(pulse_time * 3.0) % 4

	for i in range(phase):
		dots += "."

	draw_string(
		font,
		Vector2(390, 343),
		"Tiger Strategist" + dots,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		21,
		tiger_color
	)


# ============================================================
# BUTTON DRAWING
# ============================================================

func draw_button(rect, text, color):
	draw_rect(
		rect,
		Color("#1E303B")
	)

	draw_rect(
		rect,
		color,
		false,
		2.0
	)

	draw_string(
		font,
		Vector2(rect.position.x + 15, rect.position.y + 27),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		white_color
	)


# ============================================================
# INSTRUCTIONS
# ============================================================

func draw_instructions():
	# Dark overlay
	draw_rect(
		Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT),
		Color(0, 0, 0, 0.78)
	)

	var box = Rect2(150, 90, 700, 525)

	draw_rect(
		box,
		Color("#16252E")
	)

	draw_rect(
		box,
		accent_color,
		false,
		3.0
	)

	draw_string(
		font,
		Vector2(200, 135),
		"HOW TO PLAY",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		30,
		accent_color
	)

	draw_string(
		font,
		Vector2(200, 175),
		"Human vs Tiger Strategist",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		17,
		blue_color
	)

	var lines = [
		"1. You control the GOATS.",
		"2. The Tiger Strategist controls all 3 TIGERS.",
		"3. Place your 15 goats on empty board points.",
		"4. After placement, move goats along connected lines.",
		"5. Tigers can move along connected lines.",
		"6. Tigers can jump over goats to capture them.",
		"7. Tigers win after capturing 5 goats.",
		"8. Goats win when all 3 tigers are blocked.",
		"",
		"CLICK a piece, then click a green highlighted point.",
		"Yellow ring = selected piece.",
		"Green ring = legal destination."
	]

	var y = 215

	for line in lines:
		draw_string(
			font,
			Vector2(200, y),
			line,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			15,
			white_color
		)

		y += 27

	draw_button(
		close_button,
		"CLOSE",
		green_color
	)


# ============================================================
# GAME OVER
# ============================================================

func draw_game_over():
	draw_rect(
		Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT),
		Color(0, 0, 0, 0.82)
	)

	var box = Rect2(190, 140, 620, 390)

	draw_rect(
		box,
		Color("#16252E")
	)

	var border_color = green_color

	if "TIGERS" in winner_text:
		border_color = tiger_color

	draw_rect(
		box,
		border_color,
		false,
		4.0
	)

	draw_string(
		font,
		Vector2(300, 230),
		winner_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		38,
		border_color
	)

	draw_string(
		font,
		Vector2(285, 275),
		winner_subtitle,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		white_color
	)

	draw_string(
		font,
		Vector2(345, 325),
		"Final Score",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		17,
		muted_color
	)

	draw_string(
		font,
		Vector2(420, 365),
		str(captured_goats) + " / " + str(TIGER_WIN_CAPTURES),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		30,
		white_color
	)

	draw_button(
		play_again_button,
		"PLAY AGAIN",
		border_color
	)


# ============================================================
# INPUT
# ============================================================

func _input(event):
	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed:
		return

	var mouse_pos = event.position

	# Game over
	if game_over:
		if play_again_button.has_point(mouse_pos):
			start_new_game()

		return

	# Instructions
	if show_instructions:
		if close_button.has_point(mouse_pos):
			show_instructions = false
			queue_redraw()

		return

	# How to play
	if how_button.has_point(mouse_pos):
		show_instructions = true
		queue_redraw()
		return

	# Restart
	if restart_button.has_point(mouse_pos):
		start_new_game()
		return

	# Human only
	if current_turn != GOAT_TURN:
		return

	if ai_thinking:
		return

	handle_player_click(mouse_pos)


# ============================================================
# PLAYER CLICK
# ============================================================

func handle_player_click(mouse_pos):
	var clicked_point = get_nearest_point(mouse_pos)

	if clicked_point == -1:
		return

	# --------------------------------------------------------
	# GOAT PLACEMENT
	# --------------------------------------------------------

	if goats_to_place > 0:
		if board[clicked_point] == EMPTY:
			board[clicked_point] = GOAT

			goats_to_place -= 1
			move_number += 1

			status_message = "Goat placed. Tiger Strategist is thinking."

			last_move_to = clicked_point

			current_turn = TIGER_TURN

			check_game_state()

			if not game_over:
				start_ai_turn()

			queue_redraw()

		else:
			show_invalid_move("Choose an empty point.")

		return

	# --------------------------------------------------------
	# NORMAL GOAT MOVEMENT
	# --------------------------------------------------------

	if selected_piece == -1:
		if board[clicked_point] == GOAT:
			select_piece(clicked_point)
		else:
			show_invalid_move("Select one of your goats.")

		return

	# Deselect
	if clicked_point == selected_piece:
		selected_piece = -1
		legal_targets.clear()
		status_message = "Selection cleared."
		queue_redraw()
		return

	# Move
	if clicked_point in legal_targets:
		move_piece(selected_piece, clicked_point)

		selected_piece = -1
		legal_targets.clear()

		move_number += 1
		current_turn = TIGER_TURN

		check_game_state()

		if not game_over:
			start_ai_turn()

		queue_redraw()

	else:
		show_invalid_move("That is not a legal goat move.")


# ============================================================
# SELECT PIECE
# ============================================================

func select_piece(index):
	selected_piece = index
	legal_targets.clear()

	for target in connections[index]:
		if board[target] == EMPTY:
			legal_targets.append(target)

	if legal_targets.is_empty():
		status_message = "This goat has no legal moves."
	else:
		status_message = "Choose a green highlighted point."

	queue_redraw()


# ============================================================
# MOVE PIECE
# ============================================================

func move_piece(from, to):
	board[to] = board[from]
	board[from] = EMPTY

	last_move_from = from
	last_move_to = to

	start_piece_animation(
		to,
		points[from],
		points[to]
	)


# ============================================================
# START PIECE ANIMATION
# ============================================================

func start_piece_animation(index, from_pos, to_pos):
	moving_piece = index
	moving_from = from_pos
	moving_to = to_pos
	moving_progress = 0.0


# ============================================================
# START TIGER STRATEGIST
# ============================================================

func start_ai_turn():
	current_turn = TIGER_TURN

	ai_thinking = true
	ai_timer = 0.75

	status_message = "Tiger Strategist is thinking..."

	queue_redraw()


# ============================================================
# TIGER STRATEGIST TURN
# ============================================================

func perform_ai_turn():
	if game_over:
		return

	# Find all possible tiger moves
	var capture_moves = []
	var normal_moves = []

	for i in range(board.size()):
		if board[i] != TIGER:
			continue

		# Captures
		var captures = get_tiger_capture_moves(i)

		for move in captures:
			capture_moves.append(move)

		# Normal moves
		for target in connections[i]:
			if board[target] == EMPTY:
				normal_moves.append([i, target])

	# Tiger Strategist priority:
	# 1. Capture
	# 2. Strategic movement
	# 3. Any legal movement

	if not capture_moves.is_empty():
		var best_capture = choose_best_ai_capture(capture_moves)

		execute_ai_capture(
			best_capture[0],
			best_capture[1],
			best_capture[2]
		)

		return

	if not normal_moves.is_empty():
		var best_move = choose_best_ai_move(normal_moves)

		execute_ai_normal_move(
			best_move[0],
			best_move[1]
		)

		return

	# No tiger movement
	current_turn = GOAT_TURN

	status_message = "Tiger Strategist is blocked. Your turn."

	check_game_state()

	queue_redraw()


# ============================================================
# TIGER CAPTURE SEARCH
# ============================================================

func get_tiger_capture_moves(tiger_index):
	var moves = []

	for goat_index in range(board.size()):
		if board[goat_index] != GOAT:
			continue

		# Goat must be connected to tiger
		if not goat_index in connections[tiger_index]:
			continue

		for landing in connections[goat_index]:
			if landing == tiger_index:
				continue

			if board[landing] != EMPTY:
				continue

			if are_collinear_jump(
				tiger_index,
				goat_index,
				landing
			):
				moves.append([
					tiger_index,
					goat_index,
					landing
				])

	return moves


# ============================================================
# COLLINEAR CHECK
# ============================================================

func are_collinear_jump(a, b, c):
	var pa = points[a]
	var pb = points[b]
	var pc = points[c]

	var ab = pb - pa
	var bc = pc - pb

	var cross = ab.x * bc.y - ab.y * bc.x

	if abs(cross) > 8.0:
		return false

	# Ensure movement is forward
	var dot = ab.dot(bc)

	return dot > 0


# ============================================================
# TIGER STRATEGIST CAPTURE CHOICE
# ============================================================

func choose_best_ai_capture(moves):
	var best = moves[0]
	var best_score = -99999

	for move in moves:
		var tiger_index = move[0]
		var goat_index = move[1]
		var landing = move[2]

		var score = 1000

		# Prefer central landing positions
		var center_distance = points[landing].distance_to(
			Vector2(500, 330)
		)

		score -= center_distance * 0.5

		# Prefer captures that give another capture opportunity
		board[tiger_index] = EMPTY
		board[goat_index] = EMPTY
		board[landing] = TIGER

		var next_captures = get_tiger_capture_moves(landing)

		score += next_captures.size() * 100

		# Restore
		board[landing] = EMPTY
		board[goat_index] = GOAT
		board[tiger_index] = TIGER

		if score > best_score:
			best_score = score
			best = move

	return best


# ============================================================
# TIGER STRATEGIST NORMAL MOVE CHOICE
# ============================================================

func choose_best_ai_move(moves):
	var best = moves[0]
	var best_score = -99999

	for move in moves:
		var from = move[0]
		var to = move[1]

		var score = 0

		# Prefer center
		var distance = points[to].distance_to(
			Vector2(500, 330)
		)

		score -= distance * 0.35

		# Prefer positions near goats
		for goat_index in range(board.size()):
			if board[goat_index] == GOAT:
				var goat_distance = points[to].distance_to(
					points[goat_index]
				)

				if goat_distance < 170:
					score += 20

				if goat_distance < 100:
					score += 30

		# Prefer moves that create future captures
		board[from] = EMPTY
		board[to] = TIGER

		var future_captures = get_tiger_capture_moves(to)

		score += future_captures.size() * 120

		board[to] = EMPTY
		board[from] = TIGER

		if score > best_score:
			best_score = score
			best = move

	return best


# ============================================================
# TIGER STRATEGIST NORMAL MOVE
# ============================================================

func execute_ai_normal_move(from, to):
	move_piece(from, to)

	move_number += 1

	status_message = "Tiger Strategist moved. Your turn."

	current_turn = GOAT_TURN

	check_game_state()

	queue_redraw()


# ============================================================
# TIGER STRATEGIST CAPTURE
# ============================================================

func execute_ai_capture(tiger_index, goat_index, landing):
	# Remove captured goat
	board[tiger_index] = EMPTY
	board[goat_index] = EMPTY
	board[landing] = TIGER

	captured_goats += 1

	last_move_from = tiger_index
	last_move_to = landing

	capture_flash = 1.0

	start_piece_animation(
		landing,
		points[tiger_index],
		points[landing]
	)

	move_number += 1

	status_message = "Tiger captured a goat! Captured: " + str(captured_goats) + "/" + str(TIGER_WIN_CAPTURES)

	if captured_goats >= TIGER_WIN_CAPTURES:
		game_over = true
		winner_text = "TIGERS WIN!"
		winner_subtitle = "The Tiger Strategist captured 5 goats."
		current_turn = TIGER_TURN
		return

	current_turn = GOAT_TURN

	check_game_state()

	queue_redraw()


# ============================================================
# FIND NEAREST BOARD POINT
# ============================================================

func get_nearest_point(mouse_pos):
	var closest = -1
	var closest_distance = CLICK_RADIUS

	for i in range(points.size()):
		var distance = mouse_pos.distance_to(points[i])

		if distance <= closest_distance:
			closest_distance = distance
			closest = i

	return closest


# ============================================================
# INVALID MOVE
# ============================================================

func show_invalid_move(message):
	status_message = message
	invalid_flash = 0.35

	queue_redraw()


# ============================================================
# GAME STATE CHECK
# ============================================================

func check_game_state():
	if game_over:
		return

	# Tiger victory
	if captured_goats >= TIGER_WIN_CAPTURES:
		game_over = true
		winner_text = "TIGERS WIN!"
		winner_subtitle = "The Tigers captured 5 goats."
		return

	# Goat victory
	if all_tigers_blocked():
		game_over = true
		winner_text = "GOATS WIN!"
		winner_subtitle = "All three Tigers are blocked."
		return


# ============================================================
# TIGER BLOCK CHECK
# ============================================================

func all_tigers_blocked():
	var tiger_found = false

	for i in range(board.size()):
		if board[i] != TIGER:
			continue

		tiger_found = true

		# Normal move available?
		for target in connections[i]:
			if board[target] == EMPTY:
				return false

		# Capture available?
		var captures = get_tiger_capture_moves(i)

		if not captures.is_empty():
			return false

	return tiger_found


# ============================================================
# ESCAPE KEY
# ============================================================

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if show_instructions:
				show_instructions = false
				queue_redraw()
