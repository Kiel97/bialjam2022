pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- main

function _init()
 startgame()
end

function _update()
	if mode=="game" then
		update_game()
	elseif mode=="gameover" then
		update_gameover()
	end
end

function _draw()
 if mode=="game" then
 	draw_game()
 elseif mode=="gameover" then
  draw_gameover()
 end
end

function startgame()
 mode="game"
 score=0
 timer=0
	
	player={
	 track=1,
	 shape=1,
	 _x=-1,
	 _y=111,
	}
	
	tracks_x={31,63,95}
	
	bgstrips={}
	for i=-8,127,8 do
		add(bgstrips,{y=i})
	end
	
	obstacles={}
	spawn_obstacle()
end

function gameover()
	mode="gameover"
end
-->8
-- draw

function draw_game()
	cls(2)
	draw_background()
	draw_strips(true)
	draw_player()
	draw_obstacles()
	draw_score()
end

function draw_gameover()
	cls(2)
	draw_background()
	draw_strips(false)
	cprint("game over",60)
end

function draw_background()
	-- draw tracks
	rectfill(20,0,43,127,15)
	rectfill(52,0,75,127,15)
	rectfill(84,0,107,127,15)
	
	-- 1-pixel lines
	line(21,0,21,127,2)
	line(42,0,42,127,2)
	
	line(53,0,53,127,2)
	line(74,0,74,127,2)
	
	line(85,0,85,127,2)
	line(106,0,106,127,2)
end

function draw_strips(animate)
	-- animate strips
	for strip in all(bgstrips) do
		rectfill(47,strip.y,48,strip.y+4,15)
		rectfill(79,strip.y,80,strip.y+4,15)
  
  if animate then
		 strip.y+=1
		 if strip.y>=128 then
		 	strip.y=-8
   end
  end
  
	end
end

--function draw_player_n_obstacles()
-- local drew_player=false
-- for i=#obstacles,1,-1 do
--  local obstacle=obstacles[i]
--  if not drew_player and
--    
--  	sspr(0,8,128,40,0,obstacle.y-39)
-- end
--end

function draw_player()
	if player.shape==1 then
		_draw_ball()
	elseif player.shape==2 then
	 _draw_rectangle()
	elseif player.shape==3 then
	 _draw_square()
	end
	-- debug
 pset(tracks_x[player.track],player._y,0)
 -- end debug
end

function draw_score()
 local s = "score: "..score
	cprint(s,8,1)
end

function draw_obstacles()
	for obstacle in all(obstacles) do

  -- draw beginning
  map(0,0,0,obstacle.y-24,2,3)
  -- draw left track
  map(4,3,16,obstacle.y-24,4,3)
  -- draw mid track
  map(0,6,48,obstacle.y-24,4,3)
  -- draw right track
  map(4,6,80,obstacle.y-24,4,3)
  -- draw ending
  map(2,0,112,obstacle.y-24,2,3)

  -- debug
		line(0,obstacle.y,127,obstacle.y,8)
		pset(obstacle.pass,obstacle.y,obstacle.shape+9)
		-- end debug
	end
end
-->8
-- update

function update_game()
 timer+=1
 
 if timer%30==0 then
 	score+=1
 end
 
 if timer%90==0 then
  spawn_obstacle()
 end
 
 if btnp(0) then
  player.track-=1
  if player.track<1 then
  	player.track=1
  end
 end
 if btnp(1) then
  player.track+=1
  if player.track>3 then
  	player.track=3
  end
 end

 if btnp(5) then
  local shapes={1,2,3}
  del(shapes,player.shape)
 	player.shape=rnd(shapes)
 end

 player._x=tracks_x[player.track]
 
 for obst in all(obstacles) do
 	obst.y+=1
 	if obst.y>=168 then
 		del(obstacles,obst)
		end
 	
 	-- collision player and obstacle
 	if not obst.triggered and
 	   obst.y==player._y then

 	 obst.triggered=true
 		if obst.pass==player._x and
 		  obst.shape==player.shape then
    score+=10
 		else
 		 gameover()
			end
			
		end
 end
end

function update_gameover()
	
end
-->8
-- tools/helpers
function cprint(text,y,col)
	print(text,64-#text*2,y,col)
end

function spawn_obstacle()
	local obst={
	 y=0,
	 pass=tracks_x[rnd({1,2,3})],
	 shape=rnd({1,2,3}),
	 triggered=false,
	}
	add(obstacles,obst)
end
-->8
-- draw helpers

function _draw_ball()
 local px=player._x
 local py=player._y
 
 -- shadow
 ovalfill(px-3,py-1,px+4,py+1,5)
 
 -- ball
 ovalfill(px-3,py-7,px+4,py,10)
 oval(px-3,py-7,px+4,py,9)
 
 -- highlight
 rectfill(px+1,py-5,px+2,py-4,7)
end

function _draw_rectangle()
 local px=player._x
 local py=player._y
 
 -- shadow
 rectfill(px-6,py-2,px+7,py+3,5)
 line(px-7,py-1,px-7,py+2)
 line(px+8,py-1,px+8,py+2)
 
 -- rectangle floats
 py-=14
 
 -- rectangle
 rectfill(px-6,py-2,px+7,py+3,11)
 line(px-7,py-2,px-7,py+3,3)
 line(px+8,py-2,px+8,py+3,3)
 line(px-6,py-3,px+7,py-3,3)
 line(px-6,py+4,px+7,py+4,3)
 
 -- highlight
 line(px+4,py-1,px+6,py-1,7)
 pset(px+6,py,7)
 
 -- anti-highlight
 line(px-5,py+2,px-3,py+2,3)
 pset(px-5,py+1,3)
end

function _draw_square()
 local px=player._x
 local py=player._y
 
 -- shadow
 rectfill(px-11,py,px+12,py+3,5)
 line(px-10,py+4,px+11,py+4,5)

 -- square
 rectfill(px-10,py-22,px+11,py-1,12)
 line(px-10,py-23,px+11,py-23,1)
 line(px-10,py,px+11,py,1)
 line(px-11,py-22,px-11,py-1,1)
 line(px+12,py-22,px+12,py-1,1)
 
 -- highlight
 line(px+7,py-21,px+10,py-21,7)
 line(px+10,py-21,px+10,py-18,7)
 
 -- anti-highlight
 line(px-9,py-2,px-6,py-2,1)
 line(px-9,py-4,px-9,py-2,1)
end

__gfx__
00000000000000000005555555555000555555555777777755555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000057777777777500777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00700700000000000577777777777750777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00077000000000005777777777777775777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00077000000000005777777777777775777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00700700555555555777777777777775777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00000000777777775777777777777775777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00000000777777775777777777777775777777775777777777778888888877770000000000000000000000000000000000000000000000000000000000000000
00000000777777775777777777777775777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
55555555666666665777777777777775777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
77777777555555555777777777777775777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
77777777000000005777777777777775777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
77777777000000005677777777777765777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
66666666000000000567777777777650777777777777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
55555555000000000056666666666500666666667777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
00000000000000000005555555555000555555557777777577778888888877770000000000000000000000000000000000000000000000000000000000000000
55550000000055555555555555555555555555555555555577778888888877770000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888888887777777788888888777777778888888877770000000000000000000000000000000000000000000000000000000000000000
77500000000005777777858888885777777788888888777777778888888877770000000000000000000000000000000000000000000000000000000000000000
77750000000057777777885888887577777788888858777777778888888877770000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888558887577777788888858777777778888888877770000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888885587755777788855858777777778888888877770000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888888855757777788588858777766664444444466660000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888888887557777785888588777755555555555555550000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888888855755777758888588777785555555555555580000000000000000000000000000000000000000000000000000000000000000
77500000000005777777885888587757557588888588777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888555887775775788885888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888855887775757585555888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888588557775577558858888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77500000000005777777855888885575777558588888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77750000000057777777855888887755575755888888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77500000000005777777885888887575555755888888777785555555555555580000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888588885757757588588888777788886555555688880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888858855577755758858888777788885000000588880000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888885555577755785855888777788840000000048880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888558587777775788558588777788840000000048880000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888888855777777788858858777788840000000048880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888888887557777788858888777788840000000048880000000000000000000000000000000000000000000000000000000000000000
66650000000056666666444444446666666644444444666644440000000044440000000000000000000000000000000000000000000000000000000000000000
55550000000055555555555555555555555555555555555555550000000055550000000000000000000000000000000000000000000000000000000000000000
__map__
0002030006070607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1005151016171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0012130026272627000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2000002106070607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3000003116363717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000004126272627000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2223242506070607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3233343516171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4243444526464727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
