"""Diseño de dificultad aplicado una sola vez a la geometría base del generador.

No corre en el juego. Protege objetivos, checkpoints, puzle y arenas; guarda
los cruces nuevos para comprobarlos con la física real de Godot.
"""
import json


def apply(levels, write):
    routes = []
    report = []
    for level in levels:
        tier = level.index // 3
        gap = [192, 208, 218, 230][tier]
        protected = [(x - 84, x + 84, y) for kind, x, y, props in level.entities
                     if kind in ('Checkpoint', 'InteractiveTerminal', 'CrystalSwitch', 'EnergyDoor')]
        protected.append((level.exit[0] - 100, level.exit[0] + 100, level.exit[1]))
        protected.append((level.spawn[0] - 100, level.spawn[0] + 100, level.spawn[1]))
        for kind, x, y, props in level.entities:
            if kind == 'Boss':
                protected.append((props['arena_left'] - 160, level.width, y))
        floors, cuts = [], []
        for x, y, width, height in level.floors:
            # El descenso usa su serpentina y descansos: no abrir agujeros que
            # permitan saltarse los objetivos cayendo varios pisos de golpe.
            if width < 530 or level.index == 8:
                floors.append((x, y, width, height))
                continue
            candidates = range(x + 120, x + width - gap - 120 + 1, 16)
            cut = next((a for a in candidates if not any(
                abs(py-y) < 65 and a < right and a+gap > left
                for left, right, py in protected) and not any(
                0 < y-fy < 140 and a-90 < fx+fw and a+gap+50 > fx
                for fx,fy,fw,fh in level.floors if fh==12)), None)
            if cut is None:
                floors.append((x, y, width, height))
                continue
            left = (x, y, cut-x, height)
            right = (cut+gap, y, x+width-cut-gap, height)
            floors.extend((left, right))
            cuts.append((cut, cut+gap, y))
            routes.append(dict(section=level.index, start=list(left), target=list(right), gap=gap))
            level.label(cut+12, y-90, 'SALTO + DASH →\nK / E / X en el aire')
        level.floors = floors
        # El arte provisional no debe aparentar un puente sobre un hueco nuevo.
        decorations = []
        for dx,dy,kind,size in level.decorations:
            if any(abs(dy-cy)<1 and dx-size[0]/2 < b and dx+size[0]/2 > a for a,b,cy in cuts):
                choices = [max(fx+size[0]/2+10,min(dx,fx+fw-size[0]/2-10))
                           for fx,fy,fw,fh in floors if fy==dy and fw>=size[0]+20]
                if choices: dx = min(choices,key=lambda cx:abs(cx-dx))
            decorations.append((dx,dy,kind,size))
        level.decorations = decorations
        # Marcar la ruta principal aunque sus nuevos apoyos midan menos de 300.
        level.route_surfaces = set(i for i, f in enumerate(floors) if f[3] == 48)
        entities = []
        for kind, x, y, props in level.entities:
            if kind == 'Hazard':
                if any(abs(y-cy)<3 and x < b+20 and x+props['width'] > a-20 for a,b,cy in cuts):
                    continue
                props.update(rest_time=0.70-tier*0.08, warning_time=0.48-tier*0.035,
                             active_time=1.45+tier*0.18, damage=2)
                props['width'] = min(100.0, props['width']*1.45)
            elif kind == 'BaseEnemy':
                for a,b,cy in cuts:
                    if abs(y-cy)<3 and a-25 < x < b+25: x = b+70
                props.update(max_health=110+tier*15, speed=72.0+tier*8,
                             attack_style='brute' if tier >= 2 else 'duelist',
                             combo_strikes=2 if tier >= 1 else 1)
                props['patrol_distance'] = min(55.0,props['patrol_distance'])
            elif kind == 'MovingPlatform':
                props.update(width=64.0 if tier < 2 else 56.0,
                             duration=max(2.2,props['duration']*0.65),
                             collapse_delay=0.32-tier*0.025, return_delay=2.4)
            elif kind == 'Boss':
                props['max_health'] = 720 if props['saren'] else 450
            entities.append((kind,x,y,props))
        level.entities = entities
        # Defensores en espacios transitables; sin aparecer sobre un checkpoint
        # o en la cámara de resonadores. Distintas distancias fuerzan a acercarse.
        added = 0
        for x,y,width,height in floors:
            if height != 48 or width < 290: continue
            if any(kind=='Boss' and x+width > props['arena_left']-150 for kind,_,_,props in entities): continue
            if level.index == 4 and 1940 <= x <= 3900: continue
            ex = x+width*0.62
            if any(abs(ey-y)<65 and abs(ex-px)<160 for kind,px,ey,_ in entities
                   if kind in ('Checkpoint','BaseEnemy','InteractiveTerminal','CrystalSwitch')): continue
            level.add('BaseEnemy',ex,y,max_health=95+tier*15,patrol_distance=42.0,
                      speed=78.0+tier*8,attack_style='ranged' if added%2==0 else 'duelist',
                      combo_strikes=2 if tier>0 else 1)
            added += 1
        # Tramos de pulsos anchos: esperar el aviso, saltar y atravesar con dash.
        for x,y,width,height in floors:
            if height != 48 or width < 450: continue
            hx = x+width-160
            if any(abs(py-y)<65 and hx < b+50 and hx+100 > a-50 for a,b,py in protected): continue
            if any(kind=='Hazard' and abs(ey-y)<3 and abs(ex-hx)<170 for kind,ex,ey,_ in level.entities): continue
            level.add('Hazard',hx,y,width=100.0,cycle=True,phase_offset=float((x%7)*0.17),
                      rest_time=0.65-tier*0.07,warning_time=0.45,active_time=1.6+tier*0.2,damage=2)
        if level.index == 8:
            # Repisas centrales estrechas, y pulsos alternados en el descenso.
            level.floors = [(x+28,y,64,h) if w==120 and h==12 else (x,y,w,h)
                            for x,y,w,h in level.floors]
            for x,y in [(930,600),(440,1200),(930,1800)]:
                level.add('Hazard',x,y,width=84.0,cycle=True,phase_offset=y/500.0,
                          rest_time=0.45,warning_time=0.45,active_time=1.9,damage=2)
        level.entry_hint = 'RETO: salto + dash (K/E/X) · 1 dash aéreo por salto · verde: contraataca'
        level.labels = [(x,y,t.replace('0,85 s','0,3 s').replace('Dos segundos de reposo antes del aviso','Ventana breve: observa el amarillo y cruza')
                         .replace('J encadena golpes · arco amarillo: aléjate','Amarillo: dash para esquivar · verde: contraataca'))
                        for x,y,t in level.labels]
        report.append(dict(section=level.index,dash_gaps=len(cuts),
                           enemies=sum(e[0]=='BaseEnemy' for e in level.entities),
                           hazards=sum(e[0]=='Hazard' for e in level.entities)))
    write('data/dash_routes.json',json.dumps(routes,indent=2)+'\n')
    write('data/challenge_manifest.json',json.dumps(report,indent=2)+'\n')
    print('RETO:',sum(r['dash_gaps'] for r in report),'cruces con dash,',
          sum(r['enemies'] for r in report),'enemigos,',sum(r['hazards'] for r in report),'peligros')
