pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
left,right,up,down,btn_o,btn_x=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

--game loop
function _init()
   map_setup()
   init_menu()
   make_npcs()
   make_player()
   music(0)
end


function init_menu()
 _update = update_menu
 _draw = draw_menu
end

function init_game()
  music(7)
  text_setup()
  chat_setup()
  
    
  game_win=false
  game_over=false

   -- set state
   fog=blankmap(0,31,1,32)
   fogcolor=blankmap(0,255,0,255)
   _update = update_game
   _draw = draw_game
   
end

function update_menu()
  
 
 if btnp(❎) then
   init_game()  
 end
end

function update_game()
 if (not game_over) then
  if (not active_text) then
   if (not active_chat) then
    update_map()
    anim_npcs()
    fly()
    move_player()
    check_win_lose()
   end
  end 
 else
  if (btnp(❎)) then 
    extcmd("reset")
  end
 end  
end

function anim_npcs() 
  anim_gnpcs()
  anim_dnpcs()
end

function anim_gnpcs()
  for i=0,#allgold do
   if allgold[i]!=nil then
    if (allgold[i].state==npc_state_idle) then
     anim_npc(
      g_p_idle_start_spr,
      g_p_idle_end_spr,
      allgold[i]
    )	   
    end
    if (allgold[i].state==npc_state_dead) then 
     anim_npc(
      g_p_dead_start_spr,
      g_p_dead_end_spr,
      allgold[i]
    )	
    end
    if (allgold[i].state==npc_state_happy) then 
     anim_npc(
      g_p_happy_start_spr,
      g_p_happy_end_spr,
      allgold[i]
    )	
    end 
   end
  end
end

function anim_dnpcs()
  for i=0,#alldark do
   if alldark[i]!=nil then
    if (alldark[i].state==npc_state_idle) then
     anim_npc(
      d_c_idle_start_spr,
      d_c_idle_end_spr,
      alldark[i])	   
    end
    if (alldark[i].state==npc_state_dead) then 
     anim_npc(
      d_c_dead_start_spr,
      d_c_dead_end_spr,
      alldark[i])	
    end
    if (alldark[i].state==npc_state_happy) then 
     anim_npc(
      d_c_happy_start_spr,
      d_c_happy_end_spr,
      alldark[i])	
    end 
   end
  end
end

function anim_npc(anim_startspr,anim_endspr,anim_npc)
  anim_npc.delay=anim_npc.delay-1
   if anim_npc.delay<0 then
    anim_npc.sprite=anim_npc.sprite+1
   if anim_npc.sprite>anim_endspr then
    anim_npc.sprite=anim_startspr
   end
   anim_npc.delay=4
   end
 end	


function draw_menu()
 cls()

 spr(65,12,20,13,7) 
for n=1,3 do
  circ(rnd(128), rnd(64), rnd(2), rnd{6,7,12})
end
 fly()
 spr(p.sprite, 7*8, 11*8)
 
for n=1,3 do

 print("press ❎ to start",30,104,rnd{2,6,7,12,13,14})
end 
end

function draw_game()
 cls()
 
 if (not game_over) then
  draw_map()

  draw_player()
  draw_text()
  draw_chat()
--  if (btn(❎)) show_inventory()
 else
  draw_win_lose()
 end
end



-->8
-- map code

function map_setup()
-- timer
fate=0 -- no npc encounter
conf_txt=false
delay_txt=8
timer=0
timer2=0
anim_time=30 --30 = 1 second
anim_time2=1
hscore=0
kscore=0
activ_frenx=0
activ_freny=0
-- map tile settings
 wall={6,8,9,16,17,28,29,31,39,42,43,44,45,46,48,49,55,58,59,60,61,62,63,110,112}
 key={14}
 door={6}
 anim1={10,45,61}
 anim2={11,46,62}
 
 allgoldcount=0
 alldarkcount=0

 npc_state_idle=0
 npc_state_dead=1
 npc_state_happy=2

 g_p_idle_start_spr=16
 g_p_idle_end_spr=21
 g_p_dead_start_spr=32
 g_p_dead_end_spr=36
 g_p_happy_start_spr=48
 g_p_happy_end_spr=52

 d_c_idle_start_spr=22
 d_c_idle_end_spr=27
 d_c_dead_start_spr=37
 d_c_dead_end_spr=41
 d_c_happy_start_spr=53
 d_c_happy_end_spr=57

 darkcreature=d_c_idle_start_spr
 goldperson=g_p_idle_start_spr

 activ_fren=nil
 trap1={94}
 trap2={95}
 text={80}
 lose={78,94}
 win={10,11}
 gold={24}
 heart1={12}
 heart2={13}
 buttonoff={8}
 buttonon={9}
 currentb=buttonoff
 groundbtnon={58}
 groundbtnoff={62}
 triggerspike={64}
 onspike={65}
 offspike={66}
 
end
function update_map()
  if(timer<0) then
  toggle_tiles()
  timer=anim_time
  end
 timer-=1
 
  if(timer2<0) then
   toggle_traps()
   timer2=anim_time2
  end
 timer2-=1
end

function draw_map()
 mapx=flr(p.x/16)*16
 mapy=flr(p.y/16)*15
 camera(mapx*8,mapy*8)

 map(0,0,0,0,128,64)
 draw_npcs()
 rectfill(mapx*8,mapy*8,128*4,mapy*8+7,0)
 print("life: ♥".. hscore,mapx*8,mapy*8, 7, 1)
 print("wisp fire: ".. p.keys,mapx*8+48,mapy*8, 7, 1)

 for fogx=0,31 do
  for fogy=1,32 do
   if fog[fogx][fogy]==0 and fogy != 15 then
    rectfill2(fogx*8,fogy*8,8,8,0)
   end
   if fog[fogx][fogy]==2 then
    partfog(fogx,fogy)
   end
  end
 end
end

function rectfill2(_x,_y,_w,_h,_c)
  rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function blankmap(x1,x2,y1,y2)
  local ret={} 
   for x=x1,x2 do
    ret[x]={}
   for y=y1,y2 do
    ret[x][y]=0
   end
  end
  return ret
 end

function is_tile(tile_type,x,y)
 tile=mget(x,y)
 for i=1,#tile_type do
  if (tile==tile_type[i]) return true
 end
 return false
end


function can_move(x,y)
 return not is_tile(wall,x,y)
end
 
-- animate the items
function swap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile+1)
end

-- animate the traps
function unswap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile-1)
end

  --add up keys and make them dissapear
function get_key(x,y)
 p.keys+=1
 kscore+=1
 unswap_tile(x,y)
 sfx(1)
end 

function open_door(x,y)
 p.keys-=1
 kscore-=1
 swap_tile(x,y)
 sfx(2)
end

function get_heart(x,y)
 p.hearts+=1
 hscore+=1
 swap_tile(x,y)
 sfx(1)
end

function give_heart(x,y)
 if (p.hearts>0) then
 p.hearts-=1
 hscore-=1
 fate=2
 activ_fren.state=npc_state_happy

 if (activ_fren.npc_type==darkcreature) then
  activ_fren.sprite=d_c_happy_start_spr
 elseif(activ_fren.npc_type==goldperson) then
  activ_fren.sprite=g_p_happy_start_spr
 end

 sfx(5)
 end
end

function push_button(x,y)
 swap_tile(x,y)
 currentb=buttonon
  sfx(4)
end

function unpush_button(x,y)
 unswap_tile(x,y)
 currentb=buttonoff
  sfx(4)
end

function step_on(x,y)
  currentb=buttonoff
end


-->8
-- player code
 delay=4
 
 
function make_player()
 p={}
 p.x=2
 p.y=3
 p.ox, p.oy = 0, 0
 p.shake = 0
 p.sprite=1
 p.keys=0
 p.hearts=0
-- p.gold=0
 p.yellow=0
 p.black=0
end
  
function draw_player()
  if p.shake > 0 then
    p.shake -= 1
  end
  shake_x = p.shake * (rnd(12)/12 - 0.5)
  shake_y = p.shake * (rnd(12)/12 - 0.5)
  spr(p.sprite, p.x*8+p.ox+shake_x, p.y*8+p.oy+shake_y)
end

function make_npcs()
  make_gnpcs()
  make_dnpcs()
end

function make_gnpcs()
  allgold={}
  make_gnpc(4,3,"hi! am AAAAAAA boy.")
  -- make_gnpc(5,3,"hi! am BBBB boy.")
  -- make_gnpc(6,3,"hi! am CCCCC boy.")
  -- make_gnpc(24,8,"i am so lonely... :(")
  -- make_gnpc(25,4,"hug me please ♥")
  -- make_gnpc(10,8,"NO HUg PLS")
end


function make_dnpcs()  
  alldark={}
  -- make_dnpc(10,7,"hey! am dark fren")
  -- make_dnpc(24,10,"nobody loves dark fren :(")
  -- make_dnpc(27,4,"dark fren needs hug ♥")
  make_dnpc(4,4,"test")
end

function make_gnpc(nx,ny,npc_chat)
  make_npc(nx,ny,goldperson,npc_chat)
end

function make_dnpc(nx,ny,npc_chat)
  make_npc(nx,ny,darkcreature,npc_chat)
end

function make_npc(nx,ny,nspr,npc_chat)
  local n={}
  n.x=nx
  n.y=ny
  n.chat=npc_chat
  n.delay=4
  n.npc_type=nspr
  n.sprite=nspr
  n.state=npc_state_idle
  if (nspr==goldperson) then
    allgold[allgoldcount]=n
    allgoldcount+=1
  end
  if (nspr==darkcreature) then
    alldark[alldarkcount]=n
    alldarkcount+=1
  end
end 

function draw_npcs()  
  draw_gnpcs()
  draw_dnpcs()
end

function draw_gnpcs()
  for i=0,#allgold do
    draw_npc(allgold[i])
  end
end

function draw_dnpcs()
  for i=0,#alldark do
    draw_npc(alldark[i])
  end  
end

function draw_npc(npc_todraw)
 spr(npc_todraw.sprite, npc_todraw.x*8, npc_todraw.y*8)
end  

function move_player()
 newx=p.x 
 newy=p.y 
 
  -- move the fairy using ⬆️⬇️➡️⬅️ controls
 if (btnp(⬆️)) then
  newy-=1
  p.oy=8
 end
 if (btnp(⬇️)) then 
  newy+=1
  p.oy=-8
 end
 if (btnp(⬅️)) then 
  newx-=1
  p.ox=8
 end  
 if (btnp(➡️)) then
  newx+=1
  p.ox=-8
 end
 
 interact(newx,newy)

 if (can_move(newx,newy)) then
  p.x=mid(0,newx,127) 
  p.y=mid(0,newy,63)
  if p.ox!=0 or p.oy!=0 then
    if p.ox>0 then
      p.ox-=1
     end
     if p.ox<0 then
      p.ox+=1
     end
     if p.oy>0 then
      p.oy-=1
     end
     if p.oy<0 then
      p.oy+=1
     end
  end
 else -- cannot move
  sfx(0)
  p.ox, p.oy = 0, 0
  p.shake = 8
 end
 unfog(newx,newy)
end

function unfog(x,y)  
  for i = x-2, min(x+2,31) do
    for j = y-2, min(y+2,32) do
      if abs(x-i)<=1 and abs(y-j)<=1 and i>=0 and j>=0 then
        fog[i][j]=1
      elseif i>=0 and j>=0 and fog[i][j]!=1 then
        fog[i][j]=2
      end
    end
  end  
end

function partfog(fogx,fogy)
if fogy==0 or fogy==15 then
  return
end
  for i = fogx*8, fogx*8+7 do
    for j = fogy*8, fogy*8+7 do
      if delay==0 then
        rndcolor=flr(rnd(3)) 
        fogcolor[i][j]=rndcolor
      else
        rndcolor = fogcolor[i][j]
      end
      if rndcolor!=0 then
       rectfill(i,j,i,j,rndcolor)
      end
    end
  end    
end

function get_found_gnpc(x,y)
  for i=0,#allgold do
    if (allgold[i].x == x and allgold[i].y == y) then
      return allgold[i]
    end
  end
  return nil
end

function get_found_dnpc(x,y)
  for i=0,#alldark do
    if (alldark[i].x == x and alldark[i].y == y) then
      return alldark[i]
    end
  end
  return nil
end

function interact(x,y)

 if (is_tile(text,x,y)) then
  active_text=get_text(x,y)
 end
 
 local found_dnpc = get_found_dnpc(x,y)
 local found_gnpc = get_found_gnpc(x,y)

 if (found_dnpc != nil and found_dnpc.state==npc_state_idle) then
  activ_frenx=x
  activ_freny=y
  activ_fren=found_dnpc
  active_chat=get_chat(x,y)
 end

 if (found_gnpc != nil and found_gnpc.state==npc_state_idle) then
  activ_frenx=x
  activ_freny=y
  activ_fren=found_gnpc
  active_chat=get_chat(x,y)
 end
 
 if (is_tile(key,x,y)) then
  get_key(x,y)
 elseif (is_tile(heart1,x,y)) then
  get_heart(x,y)  
 elseif (is_tile(groundbtnon,x,y)) then
  step_on(x,y) 
 elseif (is_tile(buttonoff,x,y)) then
  push_button(x,y)
 elseif (is_tile(buttonon,x,y)) then
  unpush_button(x,y)
 elseif (is_tile(door,x,y) and p.keys>0) then
  open_door(x,y)
 end
end

function fly()
 delay=delay-1
	if delay<0 then
	p.sprite=p.sprite+1
  if p.sprite>5 then
  p.sprite=1
  end
 delay=4 
	end
end

-- green spikes function (maybe) triggers while stepping on them but with a delay

-->8
--npc interaction code

function chat_setup()
 chats={}
 for i=0,#allgold do
  add_chat(allgold[i])
 end
 for i=0,#alldark do
  add_chat(alldark[i])
 end
end 

function add_chat(npc_for_chat)
 chats[
  npc_for_chat.x+npc_for_chat.y*128
  ]
  =npc_for_chat.chat
end

function get_chat(x,y)
 return chats[x+y*128]
end

function draw_chat()
 if (active_chat) then
  chatx=mapx*8+4
  chaty=mapy*8+48
  
  rectfill(chatx,chaty,chatx+119,chaty+48,0)
  print(active_chat, chatx+4,chaty+4,1)
  print("give heart please?",chatx+4,chaty+16,6)

  if fate == 0 then
    if p.hearts == 0 then
      print("no hearts to give, press ❎ ",chatx+4,chaty+40,6)
      if btn(❎)then
       conf_txt=true       
      end
      if conf_txt==true then        
        delay_txt-=1
        print("no hearts to give, press ❎ ",chatx+4,chaty+40,8)
        sfx(6)   
      end
    end
    if p.hearts>0 then 
      decide_fate()
      print("yes 🅾️",chatx+4,chaty+40,6)
      print("no ❎",chatx+50,chaty+40,6)
     end 
  end

  if fate!=0 then
    print("yes 🅾️",chatx+4,chaty+40,6)
    print("no ❎",chatx+50,chaty+40,6)
    if conf_txt==true then
      delay_txt-=1      
     if fate == 1 then
      print("no ❎",chatx+50,chaty+40,8)
     end
     if fate == 2 then
      print("yes 🅾️",chatx+4,chaty+40,11)
     end
    end 
  end 
 end
 if (delay_txt<0) then 
  if fate==0 then    
    activ_fren.state=npc_state_dead
    if (activ_fren.npc_type==darkcreature) then
      activ_fren.sprite=d_c_dead_start_spr
     elseif(activ_fren.npc_type==goldperson) then
      activ_fren.sprite=g_p_dead_start_spr
    end
  end
  fate=0
  active_chat=nil
  delay_txt=8
  conf_txt=false
end    
end

function decide_fate()
 if (btnp(🅾️)) then 
  conf_txt=true
  fate=2
  give_heart(activ_frenx,activ_freny)
  if (activ_fren.npc_type==darkcreature) then
   p.black+=1
  elseif(activ_fren.npc_type==goldperson) then
   p.yellow+=1
  end
 
 elseif (btnp(❎)) then
  conf_txt=true
  fate=1
  activ_fren.state=npc_state_dead
  if (activ_fren.npc_type==darkcreature) then
    activ_fren.sprite=d_c_dead_start_spr
   elseif(activ_fren.npc_type==goldperson) then
    activ_fren.sprite=g_p_dead_start_spr
  end
  sfx(6) 
 end
end 

-->8
--animation code

function toggle_tiles()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(anim1,x,y)) then
    swap_tile(x,y)
   elseif (is_tile(anim2,x,y)) then
    unswap_tile(x,y)
     elseif (is_tile(trap1,x,y)) then
    if (is_tile(groundbtnoff,x,y)) then
     unswap_tile(x,y)
    end  
   end 
  end
 end
end

function toggle_traps()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(buttonon,x,y)) then
    if (currentb==buttonoff) then
     unpush_button(x,y)
    end
   elseif (is_tile(trap1,x,y)) then
    if (currentb==buttonon) then
     swap_tile(x,y)
    end 
   elseif (is_tile(buttonoff,x,y)) then
    if (currentb==buttonon) then
     push_button(x,y)
    end
   elseif (is_tile(trap2,x,y)) then
    if (currentb==buttonoff) then
     unswap_tile(x,y)
    end 
   end 
  end
 end
end


-->8
--game states

--win/lose code

function check_win_lose()
 if (is_tile(win,p.x,p.y)) then
  game_win=true
  game_over=true
 elseif (is_tile(lose,p.x,p.y)) then
  game_win=false
  game_over=true
 end
end

function draw_win_lose()
 camera()
 if (game_win) then
  print("★ you win! ★",37,64,7)
  if (p.yellow > p.black) then
    fly()
    spr(p.sprite, 7*8, 3*8)
   for n=1,3 do
   circ(rnd(128), rnd(64), rnd(2), rnd{7,9,10})
   print("you are gold friend",25,80,rnd{7,9,10})
   end
  elseif (p.black>p.yellow) then
    fly()
    spr(p.sprite, 7*8, 3*8)
   for n=1,3 do
   circ(rnd(128), rnd(64), rnd(2), rnd{1,2,13})
   print("you are dark friend",25,80,rnd{1,2,13})
   end
  elseif(p.black==0 and p.yellow==0) then
    spr(3, 7*8, 90)
   print("but you are heartless",23,80,7)
  elseif (p.black==p.yellow) then
    fly()
    spr(p.sprite, 7*8, 3*8)
   for n=1,10 do
   circ(rnd(128), rnd(64), rnd(5), rnd(15))
   circ(rnd(128), rnd(128), rnd(2), rnd(15))
   print("♥you are the best♥",25,80,rnd(15)) 
   end 
  end    
 else
  print("game over! :(",38,64,7)
 end
 print("press ❎ main menu",30,72,5) 
end 


-->8
--text code

function text_setup()
 texts={}
 add_text(4,4,"key opens door")
 add_text(15,4,"collect ♥, share love")
 add_text(4,7,"spikes can reach you\n... and hurt you!")
 add_text(5,12,"hidden secret passage\n can you find it?")
 add_text(9,11,"use rune on the wall\n to turn off red spikes")
 add_text(13,7,"choose a friend\n to share your heart with")
 add_text(11,3,"runes on the ground\n are tricky! be careful")
 add_text(26,13,"you are almost done!\n be brave")
 
end 

function add_text(x,y,message)
 texts[x+y*128]=message
end

function get_text(x,y)
 return texts[x+y*128]
end



function draw_text()
 if (active_text) then
  textx=mapx*8+4
  texty=mapy*8+48
  
  rectfill(textx,texty,textx+119,texty+31,7)
  print(active_text, textx+4,texty+4,1)
  print("press ❎ to close",textx+4,texty+23,6)
  if conf_txt==true then
    delay_txt-=1
    print("press ❎ to close",textx+4,texty+23,11)
  end 
  if (delay_txt<0) then
    active_text=false
    delay_txt=8
    conf_txt=false
  end
  if (btn(❎)) then 
    conf_txt=true
  end
 end
 end  
__gfx__
00000000770000770000000000000000000000000000000022226222222222221ddd1ddd1ddd1ddd2222e222222e222222222222222222222222222222211122
000000007c7007c700000000000000000000000007700770222212222222222211111111111111117722227777222277277277d222222222222cc1222e1ddd12
0070070007c66c707000000700000000077007707c7667c722221622222222226d1ee8166d1bb3167e7227e77e7227e77ee7ee7d2222222222c66c1221dd8dd1
0007700000677600c706607c770000777c7667c7c767767c2221d12622222222dd18881ddd13331d27e88e7227e88e727eeeee7d222222222c6776c12ed686d1
00077000006776007c6776c77c7667c7c767767c70066007221d512122222222111111111111111122877822228778e27eeeee7d222222222c6776c122e88812
007007000006600077677677c767767c706776070000000021151261222c2222166d166d166d166d2287782e2e87782227eee7d22222222222c66c122e1dd12e
00000000000000000006600070066007000660000000000021d1625122c1c22c1ddd1ddd1ddd1ddde228822222288222227e7d2222222222222cc1222e21122e
0000000000000000000000000000000000000000000000002151165121511c211111111111111111222222e222222e222227d2222222222222222222222222e2
0099940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222277777222222221d111677d67dd6
09aaa940009994000000000000000000000000000099940001ddddd000000000000000000000000000000000000000002222777677722222221d151677767766
9a999a9409aaa94000999400000000000099940009aaa9401d66666d01ddddd000000000000000000000000001ddddd0222777777677222222155621767766d6
9a797a949a999a9409aaa9400099940009aaa9409a999a941d66767d1d66767d01ddddd00000000001ddddd01d66767d22776666677772222221d621677776dd
9a999a949a797a949a999a9409aaa9409a999a949a797a9401ddddd01d66767d1d66767d00ddddd01d66767d1d66767d22777766dd6d77222221d161dd6d77dd
09aaa94009aaa9409a797a949a797a949a797a9409aaa94001d01d0001ddddd01d66666d1d67676d1d66666d01ddddd027d6667766d7d72222155d1d66d7d711
009994000099940009aaa94009aaa94009aaa9400099940001d01d0001d01d0001ddddd01d66666d01ddddd001d01d002666d66776666762215511d176666761
09419410019494100994994094999494099499400194941001dd1dd001dd1dd001dd01dd01ddddd001dd01dd01dd1dd0dd66dd6676e66d661551d1d176e66d66
0000000000000000000070000007770000077700000000000000000000007000000777000007770011e7e777771222151dd67dd6de7edd6dde7edd6d00000000
00000000000000000007070000707070007060700000000000000000000707000070707000706070112e777677712215d11677666de666d66de666d600000000
0000000000006000000060000007670000060600000000000000600000006000000767000006060052277777767712211dddd6d6d1d11dd6d1d11dd600000000
00000000000606000006d6000006d6000000000000000000000606000006d6000006d60000000000527766666777721111ddd6ddd111ddd1d111ddd100000000
00007000000070000000d0000000d0000000000000007000000070000000d0000000d0000000000052777766dd6d7711211ddddd11dddd1111dddd1100000000
000aaaa0000aaaa0000aaaa0000aaaa0000aaaa0000dddd0000dddd0000dddd0000dddd0000dddd017d6667766d7d71122e11111dd111111dd11111100000000
0aaaaa990aaaaa990aaaaa990aaaaa990aaaaa990ddddd110ddddd110ddddd110ddddd110ddddd111666d667766667652e7e1dd1111d1112111d111200000000
00999900009999000099990000999900009999000011110000111100001111000011110000111100dd66dd6676e66d6622e21115111e12121111121200000000
007d7d000000000000707d000007d00000000000000000000000000000d7d700000d700000000000dde7e77711e7e1222212221511e7e122111e212200000000
07e7e7d000707d0007e7e7d0007e7d000000000000d7d70000d7d7000d7e7e7000d7e700000000006d1e7776112e112e22212215112e112e11e7e12200000000
7eeeee7d07e7e7d0007e7d000007d000000000000d7e7e700d7e7e7000d7e700000d700000000000d1d77777511112222221122152211222522e122e00000000
7eeeee7d07eee7d00097d4000099940000999400d7eeeee70d7eee70000d700001ddddd000000000d177666655111222222e1211521122225211222200000000
07eee7d0097e7d4009aaa94009aaa94009aaa940d7eeeee70167e77001ddddd00d67667d01ddddd0117777665515e122122221115212e2225212222200000000
9a7e7d949a97da949a797a949a797a949a797a941d7eee7d1d6e71ed1d67667d1d6e11ed1d67667dd7d66677115e7e1221122111112e7e221122e22200000000
9897d894987978949899989498999894989998941d67e7ed1d66116d1d6e11ed1d66116d1d6e11ed1666d6671155e151222115551122e222112e7e2200000000
09aaa94009aaa94009aaa94009aaa94009aaa94001dd7dd001ddddd001ddddd001ddddd001ddddd0dd66dd661511551522115111151122221511e22200000000
11111111000000000000000002222222222222222200000000000000000000022222220000000000000000000000000000000000000000002222222222c222c2
22211112000000000000000022222222222222222220000000000000000000222777722000000000000000000000000000000000000000002222222222c222c2
22111222000000000000000022277777777772277720000000000000000000227222222000000000000000000000000000000000000000002222222222c222c2
22222112000000000000000022722222222222222220000000000000000000227222222000000000000000000000000000000000000000002222222222c222c2
1122222200000000000000002272222222222222222000000000000000000022722222200000000000000000000000000000000000000000222222222dcd22c2
22222112000000000000000022722222222222222220000000000000000000227222222000000000000000000000000000000000000000002222222221d12dcd
222222220000000000000000227222222222222222200002222222222000000222222200022222220002222000002222222000002222222021112111221221d1
22222222000000000000000022722222222222222200022222222222222000000000000022277772202277220002277772220002227772222222222222222212
222dd122000000000000000022722222220000000000222277777777722200022222220022722222222722222022722222220002272222222282222222222222
22d18d12000000000000000022722222220000000002277722222222222220222777722022722222222222222022722222220002272222222282222222222222
26d18dd100000000000000002e7eeeeee20000000002eeeeeeeeeeeeeeee202e7eeeee202e7eeeeeeeeeeeee202e7eeeeee20002e7eeeee22282222222222222
2d6186d10000000000000000227222222222220000022222222222222222202272222220227222222222222220227222222200022722222228e8228222222222
26618dd1000000000000000022722222227772200000222000002222222220227222222022722222202222222022722222220002272222228e7e828222222222
266616d1000000000000000022722222222222200000000000000272222220227222222022722222202222222022722222222022722222228e7e828222e22222
22618d1200000000000000002e7eeeeeeeeeee20000000000000227eeeee202e7eeeee202e7eeeee202eeee2002e7eeeeeee202e7eeeeee228e828788e8e88e8
2226d12200000000000000002e7eeeeeeeeee2200000000222222e7eeeee202e7eeeee202e7eeeee20022220002ee7eeeeee202e7eeeeee22282228228882282
22c222c20000000000000000227222222222220000000222777777222222202272222220227222222000000000222722222220272222222222222222c22cc2cc
22c222c200000000000000002272222222000000000222772222222222222022722222202272222220000000000227222222222722222222222111221221121c
22c222c200000000000000002e7eeeeee20000000022e7eeee2222eeeeee202e7eeeee202e7eeeee200000000002ee7eeeeee2e7eeeeeee2e2155f1211111111
22c222c200000000000000002e7eeeeee2000000002e7eeee200002eeeee202e7eeeee202e7eeeee2000000000002ee7eeeeeee7eeeeee202e15f512dddddddc
2dcd22c200000000000000002e7eeeeee2000000002e7eeee20022eeeeee202e7eeeee202e7eeeee20000000000002ee7eeee77eeeeeee2021d55d1ec6d66d6c
21d12dcd00000000000000002e7eeeeee2000000002e7eeeee22eeeeeeee202e7eeeee202e7eeeee200000000000002eeeeeeeeeeeeee200215dd1e2cdddddd1
221221d100000000000000002eeeeeeee20000000022eeeeeeeeee222eee202eeeeeee202eeeeeee2000000000000002eeeeeeeeeeeee2002e1112e21d66d661
22222212000000000000000022eeeeee2200000000022eeeeeeeee2022e22022eeeee22022eeeee220000000000000002eeeeeeeeeee200022222222cddddddc
c6d66d6c00000000000000000022222220000000000002222222222002220002222222000222222200000000000000000222eeeeeeee2000222e112216d66d61
1dddd001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e7eeee20000e2215f12ccdccdcc
006d06d000222222222222222222222200000000000000000000000000000000000000000000000002222222000000000002ee7eeee20000e21555f111611611
c000dd0c2227777777777777772277722000000000000000002222222000000000000000000000002227777220000000222eee7eee200000221d555111111111
cd55005c2272222222222222222222222000000000000000022277772200000000000000000000002272222220000222eeee77eeee2000002221dd12166d16d1
1ddd55d02272222222222222222222222000000000000000022722222200000000000000000000002272222220002eeee777eeeee20000002e121e221ddd1dd1
166d66d12272222222222222222222222000000000000000022722222200000000000000000000002272222220002ee7eeeeeeee2000000015e12e2211111111
cddddddc2272222222222222222222222000000000000000022722222200000000000000000000002272222220002eeeeeeeeee20000000021e2e22216d166d1
000000002222222222222222222222222000000000000000022722222200000000000000000000002272222220002eeeeeeeee20000000000000000000000000
00000000022222222272222222222222022222222022222000222222200000002222222222000000227222222000022222222200000000000000000000000000
00000000000000002272222222000000222777772222772200000000000000222222222222220000227222222000000000000000000000000000000000000000
00000000000000002272222222000000227222222227222200222222200002222777777777222000227222222000000000000000000000000000000000000000
00000000000000002e7eeeeee2000000227222222227222202227777220022777222222222222200227222222000000000000000000000000000000000000000
000000000000000022722222220000002e7eeeee2227eee202e7eeeee2002eeeeeeeeeeeeeeee2002e7eeeee2000000000000000000000000000000000000000
00000000000000002272222222000000227222222027222202272222220022222222222222222200227222222000000000000000000000000000000000000000
00000000000000002272222222000000227222222022222202272222220002220000022222222200227222222000000000000000000000000000000000000000
00000000000000002e7eeeeee2000000227222222022222202272222220000000000002722222200227222222000000000000000000000000000000000000000
00000000000000002e7eeeeee20000002e7eeeee202eeee202e7eeeee200000000000227eeeee2002e7eeeee2000000000000000000000000000000000000000
000000000000000022722222220000002e7eeeee2002222002e7eeeee2000000222222e7eeeee2002e7eeeee2000000000000000000000000000000000000000
00000000000000002e7eeeeee2000000227222222000000002272222220000222777777222222200227222222000000000000000000000000000000000000000
00000000000000002e7eeeeee2000000227222222000000002272222220022277eeeeeeeeeeee2002e7eeeee2000000000000000000000000000000000000000
00000000000000002e7eeeeee20000002e7eeeee2000000002e7eeeee2022e7eeee2222eeeeee2002e7eeeee2000000000000000000000000000000000000000
00000000000000002e7eeeeee20000002e7eeeee2000000002e7eeeee202e7eeee200002eeeee2002e7eeeeee220000000000000000000000000000000000000
00000000000000002e7eeeeee20000002e7eeeee2000000002e7eeeee202e7eeee20022eeeeee2002ee7eeeeeee2000000000000000000000000000000000000
00000000000000002eeeeeeee20000002eeeeeee2000000002e7eeeee202e7eeeee22eeeeeeee20002e7eeeeeee2000000000000000000000000000000000000
00000000000000002eeeeeeee20000002eeeeeee2000000002eeeeeee2022eeeeeeeeee222eee20002eeeeeeeee2000000000000000000000000000000000000
000000000000000022eeeeee2200000022eeeee220000000022eeeee220022eeeeeeeee2022e2200002eeeeeeee2000000000000000000000000000000000000
00000000000000000222222220000000022222220000000000222222200000222222222200222000000222222220000000000000000000000000000000000000
__gff__
0000000000000000010100000000000001010101000000000000000001010501010101010001010101000101200101200101010101010101010101000101010101000000010000000000000000000000210100000000000000000000000000000000000000000000000000000000010101000000000000000000000000000101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101050000000000000000000000200101000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1f2c2e3c3d3c3b2c2d3b2c2d3a1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2c2d3c3e400d400d4040403c2a1f2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2b3d40400d0d0d0e0d0d0d402c2d3a1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1f2a1d0d0d0d0d1c1d0d0d0d3c3d2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2d2c2d060d501c1f2d0d0d0d402a2b3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3d3c3b1e1c1d2c2d2a1d0d0d0d2c2e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2a1d40402c2d3c3d3a1f0d0d0d3c3e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2c2d0d0d3c2a1d402c2d1c1d0e1c1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3c3b0d0d402c2d063c2a1f2d1c1f2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
061c1d0d0d3c3d1e402c2e3d2c2d3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1e2c2d0d0d40402a1d3c1c1d3c3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1d3c3a1d0d0d0d2c2d1c1f1f3a1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2d1c1f2d1c1d0d3c3d2c3a1f2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3b2c2e3b2c2d0d0d0d3c2c2d3c3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
6e3c2a1d3c3d0d0d0d403c3d1c1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2a2b2c3a1f1d0d0d0d0d0d0d2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1f2e3c2c3a1f0d0d0d0d0d0d3c3e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3a2b1c1f2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2c2d2c2e3c3b0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3c2a2b3e40400d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
6e2c2e3e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3e3c3e0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2a1d400d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3c3b0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1d400d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3d0d0d0d0d1c1f1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
1f1d0d1c2b2c2d2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
3a1f1d2c2d3a2b3d1c1d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
2c3a1f1c1f2d2d3b2c2d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2a2a
__sfx__
000400001005011050130500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000002505025050270502a0502d050390503b0503e0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000002050090501405027050160500d0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000096500c650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002555029550255500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000c7700e7500c750107500c750117500c750137500c750157500c750177500c75018750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000932000000000000632000000000000333000000000000034000330003300032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000004750047500775007750077500775009750097500b7500b7500b7500c7500b7500b750097500975009750097500675006750027500275002750027500475004750047500475004750047500475004750
d7100000187261a7641a7521a7421a732135001a7661c7521c7421c7321c7221a500150531305313766157441572415742157221370010756117341171411712130001505313053137131a500150531305313713
37100000177260c7640c7520c7420c732135000c7660e7520e7420e7320e7221a50015053130531376613744137241374213722137000c7561573415714157123200015053130531371300000150531305313713
9b100000177260c7640c7520c7420c732135000c7660e7520e7420e7320e7221a5001505313053137661374413724137421372213700177261873418714187120c5230000000000000000c523000000000000000
d31000000c0000000000000000000c7710c7750c75400000187531875518734000000e7360e7350e714000001a7211a7251a714000000c7460c7450c72400000187531875518734000000c7760c7750c75400000
01100000280162b0162b0002600024056280461f0360c026280161f0160000000000260562b046230360e0262b0162301600000000001c0561f04624036100261f01624016260002b00024056280462b03624056
01100000280162b0162b0002600024056280461f0360c026280161f0160000000000260562b046230360e0262b0162301600000000001c0561f04624036100261f00024000260002b00024000280002b00024000
011000001505313053137131a5001505313053137130c7630c7650000000000000000c7000c7640c7630c7630c7650000000000000000c7000c7640c7630c7630c7650000000000000000c7000c7640c7630c763
d7100000187261a7641a7521a7421a732135001a7661c7521c7421c7321c7221a500150531305313766157441572415742157221370023726187341871418712130001505313053137131a500150531305313713
d7100000177261876418752187421873213500137661c7521c7421c7321c7221a5001d0531f0531f7661d7441d7241d7421d7221f7001a7561c7341c7141c712130001505313053137131a500150531305313713
011000000c05610046130360c02610016130160000000000000000000000000000000000000000000000000013056170460e03613026170160e016000000000011000150000c00011000150000c0000000000000
0110000011056150460c03611026150160c016000000000000000000000000000000000000000000000000000c05610046130360c026100161301600000000000000000000000000000000000000000000000000
001000001800018000180001800018012180111801118015150121501115011150150000000000000000000017000170001700017000170121701117011170151301213011130111301500000000000000000000
011000001800018000180001800018012180111801118015150121501115011150150000000000000000000017000170001700017000170121701117011170151a0121a0111a0111a01500000000000000000000
__music__
01 08090e44
00 0f0a0e4b
00 08090e0d
00 0f0a0e4d
00 08090b0d
00 0f0a0b44
02 08090b0d
01 11134344
00 12134344
00 11134344
02 12144344

