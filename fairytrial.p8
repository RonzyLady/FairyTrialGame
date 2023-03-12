pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
left,right,up,down,btn_o,btn_x=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

--game loop
function _init()
   init_menu()
   sfx(7)
end


function init_menu()
 _update = update_menu
 _draw = draw_menu
end

function init_game()
  -- set the fairy's starting position
  map_setup()
  text_setup()
  chat_setup()
  make_player()
    
  game_win=false
  game_over=false
  
   -- set state
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

function draw_menu()
 cls()
 print("✽fairy trial✽",34,40,14)
 print("press ❎ to start",30,64,7)
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
 wall={6,7,8,9,18,19,20,21,22,23,24,25,34,35,36,37,38,39,50,51,52,53,55,56,68,80}
 key={48}
 door={56}
 anim1={10,43}
 anim2={11,44}
 npc1={27} -- dark creature
 npc2={59} -- gold person
 activ_fren_type=npc1
 trap1={45}
 trap2={46}
 text={80}
 lose={43,45,65}
 win={10,11}
 gold={24}
 heart1={12}
 heart2={13}
 candyperson={26,27,58,59}
 darkcreature={28,29}
 buttonoff={8}
 buttonon={9}
 currentb=buttonoff
 groundbtnon={61}
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
 rectfill(mapx*8,mapy*8,128*4,mapy*8+8,0)
 print("life: ♥".. hscore,mapx*8,mapy*8, 7, 1)
 print("keys: ".. p.keys,mapx*8+48,mapy*8, 7, 1)
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
 swap_tile(x,y)
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
 fate=1
 swap_tile(x,y)
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

--green spikes are activated when steping on them and can be deactivated with button
--function step_new(x,y)
--  swap_tile(x,y)
--end
 
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
end

function interact(x,y)
 if (is_tile(text,x,y)) then
  active_text=get_text(x,y)
 end
 
 if (is_tile(npc2,x,y)) then
  activ_frenx=x
  activ_freny=y
  activ_fren_type=npc2
  active_chat=get_chat(x,y)
 end
 
 if (is_tile(key,x,y)) then
  get_key(x,y)
 elseif (is_tile(heart1,x,y)) then
  get_heart(x,y)
 
 elseif (is_tile(npc1,x,y)) then
  activ_frenx=x
  activ_freny=y
  activ_fren_type=npc1
  active_chat=get_chat(x,y)
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
 add_chat(10,8,"hi! am gold boy.")
 add_chat(10,7,"hey! am dark fren")
 add_chat(24,8,"i am so lonely... :(")
 add_chat(24,10,"nobody loves dark fren :(")
 add_chat(25,4,"hug me please ♥")
 add_chat(27,4,"dark fren needs hug ♥")
-- add_chat(7,3,"test") --test frens
-- add_chat(7,4,"test2")
end 

function add_chat(x,y,talk)
 chats[x+y*128]=talk
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
      print("yes 🅾️",chatx+4,chaty+40,11)
     end
     if fate == 2 then
      print("no ❎",chatx+50,chaty+40,8)
     end
    end 
  end 
 end
 if (delay_txt<0) then 
  if fate==0 then    
    unswap_tile(activ_frenx,activ_freny)
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
  fate=1
  give_heart(activ_frenx,activ_freny)
  if (activ_fren_type==npc1) then
   p.black+=1
  elseif(activ_fren_type==npc2) then
   p.yellow+=1
  end
 
 elseif (btnp(❎)) then
  conf_txt=true
  fate=2
  unswap_tile(activ_frenx,activ_freny)
--  sfx(6) fix so that only in chat the sound is called
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
   print("you are gold friend",25,80,9)
  elseif (p.black>p.yellow) then
   print("you are dark friend",25,80,2)
  elseif(p.black==0 and p.yellow==0) then
   print("but you are heartless",23,80,7)
  elseif (p.black==p.yellow) then
   print("♥you are the best♥",25,80,14)  
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
000000007700007700000000000000000000000000000000cc2cc22c1dd1ddd11ddd1ddd1ddd1ddd2222e222222e22222222222222222222c22cc22cc22cc22c
000000007c7007c700000000000000000000000007700770c12112211111111111111111111111117722227777222277277277d2222222221221122112211221
0070070007c66c707000000700000000077007707c7667c7111111111d166d116d1ee8166d1bb3167e7227e77e7227e77ee7ee7d222222221111111111111111
0007700000677600c706607c770000777c7667c7c767767ccddddddd1d1ddd11dd18881ddd13331d27e88e7227e88e727eeeee7d22222222dddddddddddddddd
00077000006776007c6776c77c7667c7c767767c70066007cc6ccd6c11111111111111111111111122877822228778e27eeeee7d22222222cd6cc66ccd6cc66c
007007000006600077677677c767767c706776070000000011d11dd1166d16d1166d166d166d166d2287782e2e87782227eee7d2222222221dd11dd11dd11dd1
000000000000000000066000700660070006600000000000111111111ddd1dd11ddd1ddd1ddd1ddde228822222288222227e7d22222222221111111111111111
000000000000000000000000000000000000000000000000166d166d111111111111111111111111222222e222222e222227d22222222222dddd166ddddddddd
222222222222222222222222c22cc22ccc2cc22cc22cc2ccc22cc22ccd66d66c22dddd22d7d77d7d2227272222222222222222221ddd1d1ddddddddddddd1ddd
22222222222222e22221112212211221c12112211221121c122112211dddddd127dddd72161661612272727222022222222222221111111ddddddddddddd1111
2222222222222e22e2155f1211111111111111111111111111111111166d66d1d7dddd7d111111112227672222222220222222226d166d1ddddddddddddd1d16
222222222e222e222e15f512ddddddddcddddddddddddddcdddddddddddddddcd7dddd7d111111112226d6222220002222222222dd1ddd1ddddddddddddd1d1d
2222222222e2222221d55d1ecd6cc66cc66d66dcc6d66d6ccd6cc26ccd6cc6cc77766777161111612222d222220d0000222000221111111ddddddddddddd1111
2222222222e22222215dd1e21dd11dd11ddddddccdddddd11dd118211dd11d1116166161d7dddd7d2222022222000d00220d0d02166d161ddddddddddddd166d
22222222222222e22e1112e2111111111d66d6611d66d66111112e8111111111d7dddd7dd7dddd7d2220002220000002208060801ddd1d1ddddddddddddd1ddd
222222222222222222222222166d166dcddddddccddddddc166d182d166d166117dddd7117dddd71200000202200002222006002111111111111111111111111
2222222122221221c22cc2cc1ddd1dddc6d66d6c16d66d611ddd2e2d1ddd1ddd27dddd72d7dddd7dd7dddd7d22222222222222222222222222222222c22cc22c
212e2d22211e2d221221121c111111111dddddd1ccdccdcc1111128211111111d7dddd7dd7dddd7d77766777222c222222202222222822222220222212211221
222222e21ee122e2111111116d166d16166d66d1116116116d1667261d166d16d7dddd7d7776677716166161220c0222220d0222220802222208022211111111
22d2122221111222dddddddcdd1ddd1dcddddddc11111111dd1d287d1d1ddd1d77766777161661611111111122202222222022222220222222202222dddddddd
222222d2221ee1d2c66cc6cc11111111cd66d66c166d16d1111e878711111111111661111111111116111161222222c2222222022222228222222202cd6cc66c
212d2e22211111121dd11d11166d166d1dddddd11ddd1dd116672e7d166d166dd6d11d6dd6dddd6dd7dddd7d22c220c0220220d022822080220220801dd11dd1
222222121ee11ee1111111111ddd1ddd166d66d1111111111dd2e8ed1ddd1dddd7dddd7dd7dddd7dd7dddd7d20c0220220d02202208022022080220211111111
22e2222221122112166d16d111111111cddddddc16d166d1117828211111111117dddd7117dddd7117dddd7122022222220222222202222222022222166d161d
22222222222222221ddd1dd121122222cd66d66c1dd1dd112e222722222e11222cccccc22cccccc222277722229994222222222222211122d2222e2222222222
777222222222222211111111155122221dddddd1111111f1e2e87872e2215f12c111111cc111111c2272727229aaa942222222222e1ddd12222212d22dd2dd22
7e777777222222226d166d1121d1e222166d66d121221551282227e2e21555f11155551111222211222767229a999a942222222221dd8dd12122222222222222
727ee7e722222222dd1ddd11221e1112cddddddd151121122e8722e2221d555115555551152dd2d12226d6229a797a94229994222ed686d1222ee82122dd22d2
7772272e2222222211111111222e1f51cc6cc66c215f11222828e8272221dd1210055551102222212222d2229a999a9429aaa94222e88812e218882222222222
eee22e2222222222166d16d12e2155f111d11dd121f55d12228222222e121e22d5555651d5dd2dd1222aaaa229aaa9429a797a942e1dd12e2222222edd2dd222
22222222222222221ddd1dd122ed55e111111111221dd5122222282215e12e2210055551102222212aaaaa9922999422989998942e21122e21212d2222222222
22222222222222221111111122e1de12166d166d2221112222e2222221e2e222d555555dd52dd2d1229999222942942229aaa942222222e2222222212222dd22
22222222222b222222222222277277d2cc2cc2cc0000000000000000000000000000000000000000222222222222222222727222000000000000000000000000
2220222222232222222022227ee7ee7dc121121c0000000000000000000000000000000000000000222222222888881227eee722000000000000000000000000
220b022222030222220102227eeeee7d1111111100000000000000000000000000000000000000002888881287ee7e81227e7222000000000000000000000000
22202222222022b2222022227eeeee7dcddddddc000000000000000000000000000000000000000087ee7e818ee8ee8122272222000000000000000000000000
2222220222b2223222222202277e77d2cd66d66c00000000000000000000000000000000000000008ee8ee812888881228888812000000000000000000000000
220220b022322030220220102227d2221dddddd1000000000000000000000000000000000000000028888812228128128e7ee781000000000000000000000000
20b02202203022022010220222222222c66d66dc0000000000000000000000000000000000000000228128122281281299e8e991000000000000000000000000
22022222220222222202222222222222cddddddc0000000000000000000000000000000000000000288188122881881228888812000000000000000000000000
76666665c6d66d6c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dd7ddd11dddd0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67d7dd71006d06d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddd7d1c000dd0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dd7ddd1cd55005c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
511111101ddd55d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222d1222166d66d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222d1222cddddddc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22211122222111220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e1ddd122e1ddd120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21d888d121dcccd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2ed686d12ed6c6d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22ed8d1222edcd120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e21d12e2e21d12e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2e21d12e2e21d12e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222212e2222212e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000101010100000000010100000101010101010301000000010001000020010101010103030300000000010000010101010001050000000000000000000000010000000000000000000000210100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1413131313131613131315131313131313131313131313151613131316131315000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2423232323232623232324230823232323232308232323242623232326232324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24111010101036101010245010102c2d2e103d10102b30243620102036101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24371010503010101011243d11102c2d10121111102d2b24203b101b20101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3413162f221006131513173f06131315131313153d0613171615101413221024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2723262332382323242332382723232423232324382308232624102423320a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1511102b102b101024111b3f105010240c2b2d513f102b333624103413131324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
241030102b10101024303b10101010242b2d102410102c123b243d2723230824000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
241010101010101024131313223f06241313131710102d101024102b2d2c1024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
341313153806131317272308323827242323233210102b371b242c302b2d2c24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
232323243f272323325010102d3f2b24302b113d11102c333624131313223f24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12100c5110502b10101010102d102b242c061313131313131317232323323824000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131710102b10101030102d102b243827230823232308233250302c3d2b24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323233210102b10101010102d102b241010102c2d3d102b2d2d2c102c2b0c24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1413131313131313131313131313131713131313131313131313131313131313000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2423232323232323232323232323232323232323232323232323232323232324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24101010101010103f1010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2410101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2110101010100c10101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131313131313131313131313131313131324000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400001005011050130500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000002505025050270502a0502d050390503b0503e0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000002050090501405027050160500d0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000096500c650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002555029550255500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000c7700e7500c750107500c750117500c750137500c750157500c750177500c75018750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000933000000000000633000000000000333000000000000033000350003500035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000004750047500775007750077500775009750097500b7500b7500b7500c7500b7500b750097500975009750097500675006750027500275002750027500475004750047500475004750047500475004750
__music__
00 01424344

