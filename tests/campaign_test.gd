extends SceneTree
## Integración de la aventura: escenas, dependencias, puzle, combate y recuperación.
var failures := 0
var gm: Node
var narrative: Node
var ui: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, text: String) -> void:
	if condition:
		print("OK: ", text)
	else:
		failures += 1
		push_error(text)

func frames(count: int = 4) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func settle() -> void:
	for i in range(12):
		await process_frame
		if not gm.transitioning:
			break
	await frames()

func run() -> void:
	gm = root.get_node("GameManager")
	narrative = root.get_node("NarrativeManager")
	ui = root.get_node("GameUI")
	gm.instant_transitions = true
	gm.new_game()
	await settle()
	check(current_scene.name == "Prologue", "Nueva partida abre prólogo")
	current_scene._finish()
	await settle()
	check(narrative.flags.has("STORY_01"), "Omitir prólogo conserva STORY_01")
	check(gm.sections.size() == 12, "Catálogo de 12 secciones")
	for index in range(12):
		gm.goto_section(index, true)
		await settle()
		ui.clear_dialogues()
		var level := current_scene
		var player = level.get_node("Player")
		check(level.get("section_index") == index, "Carga sección " + str(index + 1))
		var safe_anchors := true
		for entity in level.get_node("Entities").get_children():
			if not (entity.has_method("interact") or entity.get_script()==load("res://scripts/entities/checkpoint.gd")): continue
			var supported := false
			for surface in level.get_node("Geometry").get_children():
				var size: Vector2 = surface.get_node("CollisionShape2D").shape.size
				if absf(surface.position.y-entity.position.y)<1 and entity.position.x>=surface.position.x+13 and entity.position.x<=surface.position.x+size.x-13:
					supported = true
			if not supported: safe_anchors = false
		check(safe_anchors,"Objetivos, registros, salida y checkpoints tienen apoyo seguro")
		check(player.move_speed == 210.0 and player.jump_force == 380.0 and player.gravity == 950.0, "Parámetros de carrera y salto del HTML")
		var exit_node := level.get_node("Entities/Exit")
		exit_node.interact()
		check(not gm.transitioning, "Salida bloqueada sin objetivos")
		for entity in level.get_node("Entities").get_children():
			if entity.has_method("interact") and entity.get("state_key") != null and entity.get("required_keys").size() > 0:
				entity.interact()
				check(not gm.has_key(entity.state_key), "Dependencia bloquea uso anticipado: " + entity.state_key)
		# Recuperar un checkpoint recarga combate pero conserva un mecanismo y la historia.
		var saved_pos: Vector2 = player.global_position
		gm.checkpoint(saved_pos)
		gm.set_key("test_persistence")
		narrative.flags["TEST_SEEN"] = true
		gm.health = 1
		player.take_damage(1, player.position)
		await settle()
		ui.clear_dialogues()
		level = current_scene
		player = level.get_node("Player")
		check(gm.health == 6 and gm.has_key("test_persistence") and narrative.flags.has("TEST_SEEN"), "Muerte conserva progreso y restaura salud")
		check(player.position.distance_to(saved_pos) < 3.0, "Reaparición en checkpoint")
		if index == 4:
			level.resonate(2)
			check(level.puzzle_progress == 0 and not gm.has_key("sequence"), "Orden incorrecto reinicia sin daño")
			level.resonate(1)
			level.resonate(3)
			level.resonate(2)
			check(gm.has_key("sequence"), "Puzle I → III → II resuelto")
		# Las tareas están ordenadas; ninguna requiere un registro opcional.
		for task in gm.sections[index]["tasks"]:
			var key: String = task["key"]
			if key == "sequence":
				continue
			if key == "boss":
				var boss: Node2D
				for entity in level.get_node("Entities").get_children():
					if entity.get_script() == load("res://scripts/entities/boss.gd"):
						boss = entity
				player.position = boss.position + Vector2(-55, 0)
				await frames(2)
				ui.clear_dialogues()
				check(boss.active, "Arena activada al entrar")
				boss.mode = "warning"
				var hp: int = boss.health
				boss.take_hit(1)
				check(boss.health == hp, "Escudo protege fuera de ventana vulnerable")
				boss.mode = "rest"
				player.motion.facing = 1
				player.motion.set_state("combo_1")
				player.motion.frame_index = 4
				player.motion.attacking_this_step = true
				player.motion.combo_hit_done = false
				player._update_attack()
				check(boss.health == hp - 25, "Golpe del jugador daña al jefe vulnerable")
				player._update_attack()
				check(boss.health == hp - 25, "Un golpe no aplica daño cada fotograma")
				boss.take_hit(boss.max_health / 2)
				await frames(2)
				check(boss.phase == 2, "Jefe entra en segunda fase")
				boss.mode = "rest"
				boss.take_hit(boss.health)
				check(gm.has_key("boss"), "Victoria persiste y abre arena")
				ui.clear_dialogues()
			else:
				var found := false
				for entity in level.get_node("Entities").get_children():
					if entity.get("state_key") == key and entity.has_method("interact"):
						entity.interact()
						ui.clear_dialogues()
						found = true
						break
				check(found and gm.has_key(key), "Objetivo realizable: " + key)
		check(narrative.records.is_empty(), "Registros opcionales no necesarios para avanzar")
		await frames(2)
		for door in get_nodes_in_group("doors"):
			check(door.opened, "Puerta abierta tras resolver requisitos")
		exit_node = level.get_node("Entities/Exit")
		check(gm.requirements_met(exit_node.required_keys), "Salida habilitada al completar sección")
		# Recargar después de resolver no debe volver a cerrar una puerta.
		gm.respawn()
		await settle()
		ui.clear_dialogues()
		for door in get_nodes_in_group("doors"):
			check(door.opened, "Puerta resuelta sobrevive a reaparición")
		current_scene.get_node("Entities/Exit").interact()
		await settle()
		ui.clear_dialogues()
		check(current_scene.name == ("Epilogue" if index == 11 else "Level_%d_%d" % [(index + 1) / 3 + 1, (index + 1) % 3 + 1]), "Transición a siguiente escena")
	check(current_scene.name == "Epilogue", "Resolución abre epílogo")
	current_scene._finish()
	for index in range(1, 21):
		check(narrative.flags.has("STORY_%02d" % index), "Canon integrado: STORY_%02d" % index)
	current_scene._next()
	await settle()
	check(current_scene.name == "MainMenu", "Créditos vuelven al menú")
	narrative.read_record("REG_01")
	check(paused and narrative.records.has("REG_01"), "Registro se abre y queda archivado")
	var advance := InputEventAction.new()
	advance.action = "interact"
	advance.pressed = true
	ui._unhandled_input(advance)
	check(not paused, "F cierra la última página del registro")
	narrative.read_record("REG_01")
	check(paused, "Registro encontrado se puede releer")
	ui.clear_dialogues()
	check(not paused, "Cerrar registro devuelve el control")
	print("CAMPAÑA: ", failures, " fallos")
	quit(0 if failures == 0 else 1)
