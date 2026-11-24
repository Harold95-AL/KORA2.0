extends Control
var delayed := 6.0
var charge := 1.0
var last_health := 6
var hold := 0.0

func update_meter(delta: float, energy: float) -> void:
	var hp := GameManager.health
	if hp < last_health:
		hold = 0.28
	last_health = hp
	hold = maxf(0, hold - delta)
	if hold == 0 or hp >= delayed:
		delayed = move_toward(delayed, hp, delta * 5)
	charge = clampf(energy, 0, 1)
	queue_redraw()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(8,0),Vector2(15,7),Vector2(8,15),Vector2(1,7)]), Color("395973"))
	draw_rect(Rect2(6,4,4,7),Color("99f3ec"))
	for i in range(GameManager.MAX_HEALTH):
		var bar := Rect2(21 + i * 12, 1, 10, 7)
		draw_rect(bar, Color("29344a"))
		var fill := clampf(delayed-i,0,1)
		draw_rect(Rect2(bar.position,Vector2(roundf(fill*10),7)), Color("ffe8ac"))
		if i < GameManager.health:
			draw_rect(bar, Color("66ddc8"))
	draw_rect(Rect2(21,11,70,3), Color("29344a"))
	draw_rect(Rect2(21,11,roundf(70*charge),3), Color("b59eff"))
