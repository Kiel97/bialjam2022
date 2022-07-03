pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- highway
-- it just works"tm"

function _init()
 mainmenu()
 timer=0
 score=0
 reversed_controls=false
end

function _update()
 timer+=1
	if mode=="game" then
		update_game()
	elseif mode=="gameover" then
		update_gameover()
	elseif mode=="mainmenu" then
		update_mainmenu()
	end
end

function _draw()
 if mode=="game" then
 	draw_game()
 elseif mode=="gameover" then
  draw_gameover()
 elseif mode=="mainmenu" then
  draw_mainmenu()
 end
end

function startgame()
 mode="game"
 score=0
 speed=1
 timer=0
 next_100=1
 
	player={
	 track=1,
	 shape=1,
	 _x=-1,
	 _y=111,
	}
	
	tracks_x={31,63,95}
	shape_music={2,1,0}
	
	bgstrips={}
	for i=-8,127,8 do
		add(bgstrips,{y=i})
	end
	
	obstacles={}
	spawn_obstacle()
	
	update_speed()
	change_player_music()
end

function gameover()
	mode="gameover"
	cooler=50
	music(-1)
	sfx(3)
end

function mainmenu()
 mode="mainmenu"
 title_shape=1
 music(-1)
end
-->8
-- draw

function draw_game()
	cls(2)
	draw_background()
	draw_strips(true)
 draw_player_n_obstacles()
	draw_score()
end

function draw_mainmenu()
	cls(2)
	local col={9,11,12}
	
	draw_box(35,40,92,52,15,2)
	cprint("highway",44,col[title_shape])
	cprint("press ❎ to start!",67,15)
	cprint("or 🅾️ to reverse controls",78,15)
	print("bialjam 2022  it just works\"tm\"",3,120)

end

function draw_gameover()
	cls(2)
	
	draw_box(35,50,90,62,15,2)
	cprint("game over!!",54,2)
	cprint("score: "..score,66,15)
	
	if cooler<=0 then
	 cprint("press ❎ to start again!",98,15)
	 cprint("or 🅾️ to reverse controls",108,15)
	end
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

function draw_player_n_obstacles()
	draw_player()
	draw_obstacles()
end

function draw_player()
	if player.shape==1 then
		_draw_ball()
	elseif player.shape==2 then
	 _draw_rectangle()
	elseif player.shape==3 then
	 _draw_square()
	end
	-- debug
-- pset(tracks_x[player.track],player._y,0)
 -- end debug
end

function draw_score()
 local s = "score: "..score
 draw_box(36,4,127-36,16,2,15)
	cprint(s,8,15)
end

function draw_obstacles()
	for obstacle in all(obstacles) do
  local y=obstacle.y

  local s1=calc_seg(1,obstacle)
  local s2=calc_seg(2,obstacle)
  local s3=calc_seg(3,obstacle)

  _draw_beginning(y)
  _draw_segment(y,1,s1)
  _draw_segment(y,2,s2)
  _draw_segment(y,3,s3)
  _draw_ending(y)

  -- debug
--		line(0,obstacle.pass,obstacle.y,obstacle.shape+9)
		-- end debug
	end
end
-->8
-- update

function update_game()
 if timer%(30/speed)==0 then
 	score+=1
 	if (score/100)>0 and
 	  next_100<(score/100) then
 		sfx(7)
 		next_100+=1
		end
 end
 
 if timer%(90/next_100)==0 then
  spawn_obstacle()
 end
 
 if not reversed_controls then
  if btnp(0) then
   player.track-=1
   if player.track<1 then
  	 player.track=1
   else
   	sfx(1)
   end
  end
  
  if btnp(1) then
   player.track+=1
   if player.track>3 then
  	 player.track=3
   else
   	sfx(1)
   end
  end
  
 else
 
  if btnp(1) then
   player.track-=1
   if player.track<1 then
  	 player.track=1
   else
   	sfx(1)
   end
  end
  
  if btnp(0) then
   player.track+=1
   if player.track>3 then
  	 player.track=3
  	else
   	sfx(1)
   end
  end
  
 end
 
 if btnp(5) then
  change_shape()
 	change_player_music()
 end
 
 player._x=tracks_x[player.track]
 
 for obst in all(obstacles) do
 	obst.y+=speed
 	if obst.y>=168 then
 		del(obstacles,obst)
		end
 	
 	-- collision player and obstacle
 	if not obst.triggered and
 	   dot_line_coll(player._y,obst.y,obst.y-speed) then

 	 obst.triggered=true
 		if obst.pass==player._x and
 		  obst.shape==player.shape then
    score+=10
 		else
 		 gameover()
 		 return
			end
			
			if obst.shape==3 then
			 sfx(0)
			else
			 sfx(6)
			end
			
		end
 end
 update_speed()
end

function update_mainmenu()
	if btnp(5) then
	 reversed_controls=false
	 startgame()
	elseif btnp(4) then
	 reversed_controls=true
	 startgame()
	end
	
	if timer%15==0 then
  title_shape+=1
  if title_shape>3 then
   title_shape=1
  end
	end
end

function update_gameover()
 cooler-=1
 if cooler<=0 then
		if btnp(5) then
		 reversed_controls=false
		 startgame()
		elseif btnp(4) then
		 reversed_controls=true
		 startgame()
		end
	end
end
-->8
-- tools/helpers
function cprint(text,y,col)
	print(text,64-#text*2,y,col)
end

function spawn_obstacle()
 local track_num=rnd({1,2,3})
	local obst={
	 y=0,
	 track_num=track_num,
	 pass=tracks_x[track_num],
	 shape=rnd({1,2,3}),
	 triggered=false,
	}
	add(obstacles,obst)
end

function calc_seg(track,obstacle)
 if obstacle.track_num!=track then
 	return "solid"
 end
 
 if obstacle.shape==1 then
 	return "ball"
 elseif obstacle.shape==2 then
  return "rect"
 elseif obstacle.shape==3 then
  if obstacle.triggered then
   return "sqrt2"
  else
   return "sqrt1"
  end
 end
end

function change_player_music()
 music(3-player.shape)	
end

function dot_line_coll(ya,yb1,yb2)
	return (ya<=yb1 and ya>=yb2)
end

function change_shape()
 player.shape+=1
 if player.shape>3 then
 	player.shape=1
 end
end

function update_speed()
 local spd_shp={2,1.5,1}
 speed=spd_shp[player.shape]
   +(flr(score/100))
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
-- if x==nil and y==nil then
 local px=player._x
 local py=player._y
-- end
 
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

function _draw_beginning(y)
 map(0,0,0,y-24,2,3)
end

function _draw_ending(y)
 map(2,0,112,y-24,2,3)
end

function _draw_segment(y,t,s)
 -- y - obstacle.y
 -- t - track (1,2,3)
 -- s - shape
 
 -- translate track to x coord
 local t_x={16,48,80}
 
 -- translate shape to map's xy
 local xy_s={
  solid={4,0},
  rect={4,3},
  ball={4,6},
  sqrt1={0,6},
  sqrt2={0,3},
 }
 local mapx=xy_s[s][1]
 local mapy=xy_s[s][2]

	map(mapx,mapy,t_x[t],
	  y-24,4,3)
end

function draw_box(x1,y1,x2,y2,c1,c2)
 rect(x1+1,y1+1,x2-1,y2-1,c2)
 rectfill(x1+2,y1+2,x2-2,y2-2,c1)
 
 line(x1+1,y1,x2-1,y1,c1)
 line(x1+1,y2,x2-1,y2,c1)
 line(x1,y1+1,x1,y2-1,c1)
 line(x2,y1+1,x2,y2-1,c1)
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
77500000000005777777885888587757557588888588777751111111111111150000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888555887775775788885888777751111111111111150000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888855887775757585555888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888588557775577558858888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77500000000005777777855888885575777558588888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77750000000057777777855888887755575755888888777750000000000000050000000000000000000000000000000000000000000000000000000000000000
77500000000005777777885888887575555755888888777785555555555555580000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888588885757757588588888777788886555555688880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888858855577755758858888777788885111111588880000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888885555577755785855888777788841111111148880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888558587777775788558588777788840000000048880000000000000000000000000000000000000000000000000000000000000000
77750000000057777777888888855777777788858858777788840000000048880000000000000000000000000000000000000000000000000000000000000000
77500000000005777777888888887557777788858888777788840000000048880000000000000000000000000000000000000000000000000000000000000000
66650000000056666666444444446666666644444444666644440000000044440000000000000000000000000000000000000000000000000000000000000000
55550000000055555555555555555555555555555555555555550000000055550000000000000000000000000000000000000000000000000000000000000000
__label__
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f2221122112f11f111f111fffffffff1112111222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f221ff212f21f1f1f1f1ffff1ffffff2f122f1222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22111212f21f1f11ff11ffffffffff1112221222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22221212f21f1f1f1f1ffff1ffffff1f22221222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f221122211211ff1f1f111fffffffff1112221222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555522222222222
22222222225777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777752222222222
22222222257777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777775222222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888885555555555555588888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
55555555577777777777888851111111111111158888777777778888888877777777888888887777777788888888777777778888888877777777777555555555
77777777577777777777888851111111111111158888777777778888888877777777888888887777777788888888777777778888888877777777777577777777
7777777757777777777788885ffffffffffffff58888777777778888888877777777888888887777777788888888777777778888888877777777777577777777
7777777757777777777788885ffffffffffffff58888777777778888888877777777888888887777777788888888777777778888888877777777777577777777
6666666657777777777788885ffffffffffffff58888777777778888888877777777888888887777777788888888777777778888888877777777777566666666
5555555557777777777788885ffffffffffffff58888777777778888888877777777888888887777777788888888777777778888888877777777777555555555
22222222577777777777888885555555555555588888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222577777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777777522222222
22222222567777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777776522222222
22222222256777777777888888887777777788888888777777778888888877777777888888887777777788888888777777778888888877777777765222222222
22222222225666666666444444446666666644444444666666664444444466666666444444446666666644444444666666664444444466666666652222222222
22222222222555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555522222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff222f1111111111111111111111f22222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221ccccccccccccccccc7777c122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccc7c122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccc7c122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccc7c122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221c1cccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f222222221c1cccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221c1111ccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff2221cccccccccccccccccccccc122222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff22251111111111111111111111522222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff22255555555555555555555555522222222222222222222
22222222222222222222f2ffffffffffffffffffff2f222ff222f2ffffffffffffffffffff2f222ff22255555555555555555555555522222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f2222222255555555555555555555555522222222222222222222
22222222222222222222f2ffffffffffffffffffff2f22222222f2ffffffffffffffffffff2f22222222f5555555555555555555555f22222222222222222222
222222222225555555555555555555555555555555555555555555555555555555555555555555555555f2ffffffffffffffffffff2f55555555522222222222
222222222257777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777752222222222
222222222577777777778888888877777777888888887777777788888888777777778888888877777752f2ffffffffffffffffffff2f25777777775222222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777777522222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777752f2ffffffffffffffffffff2f25777777777522222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777777522222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777752f2ffffffffffffffffffff2f25777777777522222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777777522222222
222222225777777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777777522222222
555555555777777777778888888877777777888888887777777788888888777777778888888877777752f2ffffffffffffffffffff2f25777777777555555555
777777775777777777778888888877777777888888887777777788888888777777778888888877777775f2ffffffffffffffffffff2f57777777777577777777
777777775777777777778888888877777777888888887777777788888888777777778888888877777752f2ffffffffffffffffffff2f25777777777577777777

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
49020000316402f6402c6402c640296402964026640246402364022640216401d6401c65023600256001f6001d6001e6001b6001c60019600176001b60018600186001b600186001a60017600176001a60018600
000100001b0501e05022050250502505027050280502805029050290502805027050270502505023050200511e0511a0511a05200003000000000000000000000000000000000000000000000000000000000000
01060000120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d0430f043120430d043
010800001f3301f3301b3301b3301b3301b3301833018330183301833016330163301333013330133301333013330143301433014330143300030000300003000030000300003000030000300003000030000300
01040000070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050070500a0500c0500f050
01010000071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130071300a1300c1300f130
0003000024550275502b5502b5502e5502e5502e5502e5502b5502b55027550225501f55016500155001450014500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001a5501b5501c5501e550205502355025550275502955016550185501a5501b5501d5501f550215502555026550295502b5502d55018550195501c5501e55020550215502355025550275302a5502c550
__music__
03 02424344
03 04424344
03 05424344

