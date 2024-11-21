local helperFuncsDebug = false;
local bulletDeath = false;
local song = 'gameover';
function onCreate()
	song = (checkFileExists(currentModDirectory .. '/sounds/soul_purpose.ogg') and 'soul_purpose' or 'gameover');
end

function noteMiss(i, d, t, s)
	if t == 'Bullet Note' then
		if getHealth() <= 0 then
			bulletDeath = true;
		end
	end
end

--[[getMidpoint is hella unrealiable and the other method doesn't work either
	so guess I'll have to do it like this.
--]]
local pos = {
	['LOVE'] = {625, 440}
};
local texts = {
};
local pickedtext = 1;
local curdialogue = 1;
local blip = '';
local start = false;
local s = 0;
function onGameOver()
	if not start then
		startDeath();
		setProperty('canPause', false);
		start = true;
	end
	runHaxeCode([[
		game.vocals.stop();
		FlxG.sound.music.stop();
		FlxG.sound.music.volume = 0;
		game.vocals.volume = 0;
		//Fucking stuttering.
	]])
	return Function_Stop;
end	

local bs = false;
local inDialogue = false;
local allTextsDone = false;
local curTextDone = false;

local canExit = false;
local exiting = false;
local themeVolume = 0;
function onUpdate()
	if getProperty('soul.animation.curAnim.curFrame') == 1 then
		if not bs then
			playSound('break', 1);
			bs = true;
		end
	end
	if luaSoundExists('deathTheme') then
		themeVolume = getSoundVolume('deathTheme');
	end
	
	if getProperty('controls.ACCEPT') then
		if inDialogue then
			allTextsDone = curdialogue == #texts[pickedtext];
			if not curTextDone then
				if helperFuncsDebug then debugPrint("Skipped text."); end
				setTextString('deathTxt', getCharacters(pickedtext, true));
				playSound(blip, 1);
				cancelTimer('add');
				curTextDone = true;
			else
				if allTextsDone then
					if helperFuncsDebug then debugPrint("No more texts found, restarting song!", 'RED'); end
					local obj = {'gameover', 'spotlight', 'deadchar', 'deathTxt'};
					for o = 1, #obj do
						startTween(obj[o] .. 'fadeout', obj[o], {alpha = 0}, 2, {ease = 'linear', onComplete = 'onTweenCompleted'});
					end
					soundFadeOut('deathTheme', 2, 0);
					canExit = false;
					inDialogue = false;
				else
					if helperFuncsDebug then debugPrint("Another text found, procceding.", "BLUE"); end
					curdialogue = curdialogue + 1;
					startDialogue();
				end
			end
		end
	elseif getProperty('controls.BACK') and canExit then
		exiting = true;
		local obj = {'gameover', 'spotlight', 'deadchar', 'deathTxt'};
		for o = 1, #obj do
			startTween(obj[o] .. 'fadeout', obj[o], {alpha = 0}, 2, {ease = 'linear', onComplete = 'onTweenCompleted'});
		end
		cancelTween('spotlightf'); cancelTween('deadcharf');
		soundFadeOut('deathTheme', 2, 0);
		if inDialogue then
			inDialogue = false;
		end
	end
	
	if helperFuncsDebug then
		if keyboardPressed('CONTROL') then
			if keyboardJustPressed('R') then
				restartSong();
			elseif keyboardJustPressed('D') then
				setHealth(0);
			elseif keyboardJustPressed('B') then
				bs = false;
				danim();
			elseif keyboardJustPressed('C') then
				setProperty('soul.color', getColorFromHex(rgbToHex(getRandomInt(0, 255), getRandomInt(0, 255), getRandomInt(0, 255))));
			end
		end
	end
end

local split = {};
local display = '';
local letter = 1;
function onTimerCompleted(t, l, ll)
	if t == 'shatter' then
		setProperty('soul.alpha', 0);
		playSound('shatter', 1);
		createShard(getProperty('soul.x'), getProperty('soul.y'));
		createShard(getProperty('soul.x'), getProperty('soul.y') + 10);
		createShard(getProperty('soul.x'), getProperty('soul.y') + 20);
		createShard(getProperty('soul.x') + 25, getProperty('soul.y'));
		createShard(getProperty('soul.x') + 25, getProperty('soul.y') + 10);
		createShard(getProperty('soul.x') + 25, getProperty('soul.y') + 20);
		runTimer('gameovS', 1.1);
	elseif t == 'gameovS' then
		startTween('overin', 'gameover', {alpha = 1}, 2, {ease = 'linear', onComplete = 'onTweenCompleted'});
		playSound(song, 1, 'deathTheme');
		canExit = true;
		runTimer('otherstuff', 1);
	elseif t == 'otherstuff' then
		local o = {'spotlight', 'deadchar'};
		if not exiting then
			for i = 1, #o do
				startTween(o[i] .. 'f', o[i], {alpha = 1}, 1, {ease = 'linear'});
			end	
		end
	elseif t == 'add' then
		display = display .. split[letter];
		setTextString('deathTxt', display);
		playSound(blip, getSoundVolume('deathTheme'));
		letter = letter + 1;
		if ll == 0 then
			curTextDone = true;
		end
	end
end

function onTweenCompleted(t)
	if t == 'overin' then
		if not exiting then
			startDialogue();
			inDialogue = true;
		end
	elseif t == 'gameoverfadeout' then
		if exiting then
			exitSong();
		else
			restartSong();
			-- this caused this to crash so I don't know why.
		end
	end
end

function onSoundFinished(t)
	if t == 'deathTheme' then
		playSound(song, themeVolume, 'deathTheme');
	end
end

function startDialogue()
	--[[Reset variables.--]]
	letter = 1;
	display = '';
	curTextDone = false;
	
	--[[Cont.--]]
	split = getCharacters(pickedtext, false);
	runTimer('add', 0.05, #split);
end

local amount = 0;
function createShard(x, y)
	local t = 'shard' .. amount;
	local exclude = '';
	for i = getRandomInt(-50, -100), getRandomInt(50, 100) do exclude = exclude .. ',' .. i end
	makeLuaSprite(t, nil, x, y)
	setScrollFactor(t, s, s); 
	loadGraphic(t, 'particles/heartshard', 7, 8);
	addAnimation(t, 'shard', {0, 1, 2, 3}, 6, true);
	setProperty(t .. '.antialiasing', false);
	scaleObject(t, 1.5, 1.5);
	setProperty(t .. '.color', getProperty('soul.color'));
	setProperty(t .. '.acceleration.y', 500);
	setProperty(t .. '.velocity.y', getRandomInt(200, -600, exclude));
	setProperty(t .. '.velocity.x', getRandomInt(400, -300, exclude));
	if bulletDeath then setProperty(t .. '.velocity.x', getRandomInt(800, 1100)); end
	addLuaSprite(t, true);
	amount = amount + 1;
end

function rgbToHex(r, g, b)
    local rgb = (r * 0x10000) + (g * 0x100) + b;
    return string.format("%x", rgb);
end

local basic = {'gameover', 'spotlight', 'deadchar'};
function startDeath()
	makeLuaGraphic('g_bg', nil, nil, screenWidth, screenHeight, '000000', true);
	screenCenter('g_bg');
	setScrollFactor('g_bg', 0, 0);

	makeLuaSprite('soul', nil);
	loadGraphic('soul', 'gameover/heart', 20, 16);
	addAnimation('soul', 'break', {0, 1}, 6, false);
	addAnimation('soul', 'nbreak', {0}, 0);
	scaleObject('soul', 1.5, 1.5);
	setProperty('soul.antialiasing', false);
	setProperty('soul.alpha', 0);
	addLuaSprite('soul', true);
	
	makeLuaSprite('gameover', 'gameover/gameover', nil, 60);
	scaleObject('gameover', 1.5, 1.5);
	screenCenter('gameover', 'x');
	
	makeLuaSprite('spotlight', 'gameover/spotlight', nil, 650);
	scaleObject('spotlight', 4, 4);
	screenCenter('spotlight', 'x');
	
	local deads = currentModDirectory .. '/images/gameover/' .. getProperty('boyfriend.curCharacter') .. 'd.png';
	if checkFileExists(deads) then
		deads = getProperty('boyfriend.curCharacter') .. 'd';
	else
		deads = 'bfd';
	end
	makeLuaSprite('deadchar', 'gameover/' .. deads, nil, getProperty('spotlight.y') - 92);
	scaleObject('deadchar', 4, 4);
	screenCenter('deadchar', 'x');
	
	local path = currentModDirectory .. '/data/' .. string.gsub(songName:lower(), ' ', '-') .. '/lines.txt';
	if checkFileExists(path) then
		if helperFuncsDebug then debugPrint('Found file at: ' .. path); end
		getLines(getTextFromFile(path));
		if helperFuncsDebug then debugPrint(texts); end
	else
		if helperFuncsDebug then debugPrint("Couldn't find path at: " .. path, 'RED'); end
		texts = {
			{'Well, Flowey got you that one.'},
			{'What? Are you saying that--\nOh wait...'},
			{'He gave you a lot of pain,\ndidnt he?'},
			{'This, is the FIRST tutorial man.'}
		}
	end
	
	quickText('deathTxt', '', 323, 370, screenWidth, 40, 'left', 'FFFFFF', 'dtmmono');
	setObjectCamera('deathTxt', 'camGame');
	setTextBorder('deathTxt', 0);
	
	pickedtext = getRandomInt(1, #texts);
	
	for b = 1, #basic do
		setProperty(basic[b] .. '.antialiasing', false);
		setProperty(basic[b] .. '.alpha', 0);
		setScrollFactor(basic[b], 0, 0);
		addLuaSprite(basic[b], true);
	end
	
	s = (songName ~= 'Temperate' and 1 or 0);
	setProperty('soul.color', getColorFromHex('FF0000'));
	setScrollFactor('soul', s, s);
	
	local soul_x = pos[songName][1] or 0;
	local soul_y = pos[songName][2] or 0;
	-- if songName == 'True Reset' then
		-- soul_x = getProperty('bfsoul.x');
		-- soul_y = getProperty('bfsoul.y');
	-- end
	setProperty('soul.x', soul_x);
	setProperty('soul.y', soul_y);
	
	local blippath = currentModDirectory .. '/sounds/' .. getProperty('dad.curCharacter') .. '_blip.ogg';
	blip = (checkFileExists(blippath) and getProperty('dad.curCharacter') .. '_blip' or 'text_blip');
	
	setProperty('cameraSpeed', 1);
	setProperty('camHUD.visible', false);
	triggerEvent('Camera Follow Pos', tostring(getProperty('soul.x') + (getProperty('soul.width') / 2)), tostring(getProperty('soul.y')));
	danim();
end

local time = 1.1;
function danim()
	if bulletDeath then time = 0.12; end
	setProperty('soul.alpha', 1);
	if bulletDeath then playAnim('soul', 'break', true, false, 1); else playAnim('soul', 'break', true); end
	runTimer('shatter', time);
end

function getCharacters(c, onlyformat)
	local format = texts[c][curdialogue]:gsub('/', '\n');
	if not onlyformat then
		return stringSplit(format);
	else
		return format;
	end
end

function getLines(file)
	local lines = {};
	for i in file:gmatch('[^\n]+') do
		table.insert(lines, tostring(i));
	end
	for t = 1, #lines do
		table.insert(texts, stringSplit(lines[t], ':'));
	end
end

function makeLuaGraphic(tag, x, y, width, height, color, front)
	makeLuaSprite(tag, nil, x, y);
	makeGraphic(tag, width, height, color);
	addLuaSprite(tag, front);
end

function quickText(tag, text, x, y, width, size, alignment, color, font)
	makeLuaText(tag, text, width, x, y);
	setTextSize(tag, size)
	setTextAlignment(tag, alignment);
	setTextColor(tag, color);
	if checkFileExists(currentModDirectory .. '/fonts/' .. font .. '.ttf') then
		if helperFuncsDebug then debugPrint('Found font, type .ttf', 'GREEN'); end
		setTextFont(tag, font .. '.ttf');
	elseif checkFileExists(currentModDirectory .. '/fonts/' .. font .. '.otf') then
		if helperFuncsDebug then debugPrint('Found font, type .otf', 'GREEN'); end
		setTextFont(tag, font .. '.otf');
	else
		if helperFuncsDebug then debugPrint("Couldn't find font " .. font, 'RED'); end
	end
	addLuaText(tag);
	if helperFuncsDebug then debugPrint('Created text with tag: ' .. tag .. '\nText:' .. text .. '\nX/Y: (' .. x .. ', ' .. y .. ')' .. '\nWidth: ' .. width .. '\nSize: ' .. size .. '\nAlignment: ' .. alignment .. '\nColor: ' .. color .. '\nFont:' .. font); end
end