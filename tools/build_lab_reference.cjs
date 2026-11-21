// Ejecuta el objeto player ORIGINAL del HTML en un contexto sin navegador.
// Solo se sustituyen audio/dibujo/vibración; la lógica bajo prueba es la original.
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const root = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'tests/fixtures/lab_reference.html'), 'utf8');
function chunk(start, end) { return html.slice(html.indexOf(start), html.indexOf(end, html.indexOf(start))); }
const source = chunk('    const SPRITE_DATA =', '    const images =') + chunk('    const config =', '    // --- 4. GAME OBJECTS') + chunk('    const player =', '    // --- 6. CONTROLLER');
const fields = {x:'x',y:'y',vx:'vx',vy:'vy',facing:'facing',grounded:'isGrounded',state:'state',frame_index:'frameIndex',anim_timer:'animTimer',coyote_timer:'coyoteTimer',jump_buffer:'jumpBufferTimer',combo2_buffered:'combo2Buffered',combo3_buffered:'combo3Buffered',combo_hit_done:'comboHitDone',is_dashing:'isDashing',dash_timer:'dashTimer',dash_cooldown:'dashCooldown'};
const translate = {move_x:'moveX',is_running:'isRunning',jump_pressed:'jumpPressed',jump_held:'jumpHeld',attack_pressed:'attackPressed',heavy_pressed:'heavyAttackPressed',dash_pressed:'dashPressed'};
const floor = [{x:-10000,y:400,w:20000,h:200}];
const cases = [];
function scenario(name, count, fn, options={}) {
  const hitLog=[];
  const dummy={x:options.dummy_x ?? 10000,y:400,w:24,h:45,hit(damage){hitLog.push(damage)}};
  const context=vm.createContext({groundY:400,platforms:options.platforms ?? floor,dummy,particles:[],camera:{shake(){}},spawnDust(){},spawnGhost(){},rumbleGamepad(){},spawnHitSparks(){},playDashSound(){},playSlashSound(){},playHeavySlamSound(){},playHitSound(){},playJumpSound(){}});
  vm.runInContext(source+'\nglobalThis.playerRef=player; globalThis.configRef=config;',context);
  const p=context.playerRef;
  for (const [key,value] of Object.entries(options.initial ?? {})) p[fields[key]]=value;
  const steps=[];
  for(let i=0;i<count;i++) {
    const spec=fn(i) ?? {};
    const dt=spec.dt ?? 1/60;
    const input={move_x:0,is_running:false,jump_pressed:false,jump_held:false,attack_pressed:false,heavy_pressed:false,dash_pressed:false,...spec.input};
    if(spec.command) p[spec.command]();
    const raw=Object.fromEntries(Object.entries(input).map(([key,value])=>[translate[key],value]));
    p.update(dt,raw);
    steps.push({dt,rate:1/dt,input,command:spec.command ?? '',expected:Object.fromEntries(Object.entries(fields).map(([key,value])=>[key,p[value]])),hits:[...hitLog]});
  }
  cases.push({name,platforms:options.platforms ?? floor,initial:options.initial ?? {},dummy_x:dummy.x,steps});
}
scenario('aceleracion_frenado_giro',150,i=>({input:{move_x:i<45?1:i<70?0:i<120?-1:0}}));
scenario('stick_y_modificador',150,i=>({input:{move_x:i<40?0.4:i<80?0.74:i<110?0.75:0.2,is_running:i>=110}}));
scenario('salto_completo',130,i=>({input:{jump_pressed:i===5,jump_held:i>=5&&i<65,move_x:i>10?1:0}}));
scenario('salto_corto',100,i=>({input:{jump_pressed:i===5,jump_held:i>=5&&i<10}}));
scenario('coyote',100,i=>({input:{move_x:1,jump_pressed:i===22,jump_held:i>=22}}),{platforms:[{x:-1000,y:400,w:1060,h:20}]});
scenario('buffer_aterrizaje',120,i=>({input:{jump_pressed:i===35,jump_held:i>=35}}),{initial:{y:220}});
scenario('dash_suelo_y_recarga',100,i=>({input:{dash_pressed:[5,10,20,30,55].includes(i)}}));
scenario('dash_aereo',110,i=>({input:{jump_pressed:i===2,jump_held:i>=2&&i<35,dash_pressed:i===20,move_x:1}}));
scenario('ataque_aereo',120,i=>({input:{jump_pressed:i===4,jump_held:i>3&&i<24,attack_pressed:[16,25,43].includes(i),move_x:1}}));
scenario('combo_sin_buffer_envaine',100,i=>({input:{attack_pressed:i===2}}),{dummy_x:40});
scenario('combo_123',120,i=>({input:{attack_pressed:[2,9,27].includes(i)}}),{dummy_x:40});
scenario('combo_1_fuerte_prioritario',100,i=>({input:{attack_pressed:[2,8].includes(i),heavy_pressed:i===10}}),{dummy_x:40});
scenario('fuerte_independiente',100,i=>({input:{heavy_pressed:i===3}}),{dummy_x:40});
scenario('dash_cancela_ataque',100,i=>({input:{attack_pressed:[3,9].includes(i),dash_pressed:i===11}}));
scenario('ataque_durante_dash',100,i=>({input:{dash_pressed:i===3,attack_pressed:i===7,heavy_pressed:i===14}}),{dummy_x:95});
scenario('dt_variable',150,i=>({dt:[1/144,1/30,1/60,0.1,0.016][i%5],input:{move_x:i<90?1:0,jump_pressed:i===7,jump_held:i>6&&i<40,attack_pressed:[20,23,40].includes(i),dash_pressed:i===65}}));
for(const command of ['forceCombo1','forceCombo2','forceCombo3','forceComboEnd']) scenario(command,90,i=>({command:i===3?command:undefined}),{dummy_x:40});
fs.writeFileSync(path.join(root,'tests/fixtures/lab_traces.json'),JSON.stringify(cases));
console.log(`${cases.length} escenarios, ${cases.reduce((sum,item)=>sum+item.steps.length,0)} fotogramas del HTML original.`);
