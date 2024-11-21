local helperFuncsDebug = false;
function onCreate() setProperty('skipCountdown', true); end

function onCreatePost()
	makeLuaGraphic('bgborder_1', -800, nil, 960, 720, '000000', true);
	setObjectCamera('bgborder_1', 'camOther');
	screenCenter('bgborder_1', 'y');
	
	makeLuaGraphic('bgborder_2', 1120, nil, 960, 720, '000000', true);
	setObjectCamera('bgborder_2', 'camOther');
	screenCenter('bgborder_2', 'y');
	
	setProperty('uiGroup.visible', false); setProperty('showComboNum', false); setProperty('showRating', false);
end

local pos = {
	['LOVE'] = 466
};
--For songs that show the health bar later.
local exclusions = {'True Reset', 'Efforts Linger'};
function onSongStart()
	local hex = rgbToHex(getProperty('boyfriend.healthColorArray[0]'), getProperty('boyfriend.healthColorArray[1]'), getProperty('boyfriend.healthColorArray[2]'));
	
	makeLuaGraphic('boxbg', pos[songName] or 701, 660, 106, 22, 'FFFFFF');
	setObjectCamera('boxbg', 'camHUD');
	setProperty('boxbg.color', getColorFromHex(hex));
	scaleObject('boxbg', 3, 3);
	
	makeLuaGraphic('boxfront', getProperty('boxbg.x') + 5, getProperty('boxbg.y') + 6, 102, 18, '000000');
	setObjectCamera('boxfront', 'camHUD');
	scaleObject('boxfront', 3, 3);
	
	quickText('nameTxt', 'BOYFRI', 735, getProperty('boxbg.y') + 26, screenWidth, 15, 'left', 'FFFFFF', 'cryptoftomorrow');
	setTextBorder('nameTxt', 0);
	setObjectCamera('nameTxt', 'camHUD');
	setProperty('nameTxt.alpha', 0);
	
	quickText('healthTxt', '100/100', -265, getProperty('nameTxt.y'), screenWidth, 15, 'right', 'FFFFFF', 'cryptoftomorrow');
	setTextBorder('healthTxt', 0);
	setObjectCamera('healthTxt', 'camHUD');
	setProperty('healthTxt.alpha', 0);
	
	makeLuaGraphic('healthBarBar', 812, getProperty('nameTxt.y') + 2, 21, 5, 'FFFF00');
	setObjectCamera('healthBarBar', 'camHUD');
	scaleObject('healthBarBar', 3, 3);
	setProperty('healthBarBar.origin.x', 0);
	setProperty('healthBarBar.alpha', 0);
	
	makeLuaGraphic('healthBarBarBG', 833, getProperty('healthBarBar.y'), 21, 5, 'FF0000');
	setObjectCamera('healthBarBarBG', 'camHUD');
	scaleObject('healthBarBarBG', 3, 3);
	setProperty('healthBarBarBG.alpha', 0);
	
	local box = {'healthBarBarBG', 'healthBarBar', 'healthTxt', 'nameTxt', 'boxfront', 'boxbg'};
	for i = 1, #box do
		setObjectOrder(box[i], getObjectOrder('strumLineNotes') + 1);
	end
	setObjectOrder('healthBarBarBG', getObjectOrder('healthBarBar') - 1);
	
	for i = 1, #box do setProperty(box[i] .. '.alpha', 1); end
	
	setProperty('boxbg.y', (downscroll and 720 or -70));
	if not table.contains(exclusions, songName) then
		startTween('boxbgu', 'boxbg', {y = (downscroll and 660 or -10)}, crochet / 1000, {ease = 'quadOut'});
	end
end

local lastHealth = 0;
local difference = 0;
local boxObjects = {{'boxbg', 0, 0}, {'boxfront', 5, 6}, {'nameTxt', 19, 26}, {'healthTxt', -981, 26}, {'healthBarBar', 96, 28}, {'healthBarBarBG', 117, 28}};
function onUpdate()
	--[[
		Checks for any difference with the last health value and the current health value.
		Also calls onHealthUpdate() which actually updates everything.
	]]--
	if lastHealth ~= getProperty('healthBar.percent') then
		difference = lastHealth - getProperty('healthBar.percent');
		lastHealth = getProperty('healthBar.percent');
		onHealthUpdate();
	end
	
	--Anchor box objects to the box itself.
	for i = 1, #boxObjects do
		setProperty(boxObjects[i][1] .. '.x', getProperty('boxbg.x') + boxObjects[i][2]);
		setProperty(boxObjects[i][1] .. '.y', getProperty('boxbg.y') + boxObjects[i][3]);
		setProperty(boxObjects[i][1] .. '.alpha', getProperty('strumLineNotes.members[4].alpha'));
	end
end

function onUpdatePost()
	runHaxeCode([[
		var scale = camOther.zoom / 2;
		game.camOther.flashSprite.scaleX = camOther.flashSprite.scaleY = 2;
		game.camOther.setScale(scale, scale);
	]])
end

local moveOut = false;
function onGameOver()
	--Move off screen when it's game over and also makes it grey cause Deltarune.
	if not moveOut then
		if luaSoundExists('hurtsnd') then stopSound('hurtsnd'); end
		setProperty('boxbg.color', getColorFromHex('808080'));
		startTween('boxMoveO', 'boxbg', {y = getProperty('boxbg.y') + 100}, 0.4, {ease = 'quintIn'});
		moveOut = true;
	end
end

function onEvent(n, v1, v2)
	if n == 'Show Health Bar' then
		startTween('boxbgu', 'boxbg', {y = (downscroll and 660 or -10)}, crochet / 1000, {ease = 'quadOut'});
	end
end

--[[
I wish you could update FlxText objects every frame and not start a memory leak.
And the fact this doesn't even stop it, it just fucking mitigates it.
--]]
function onHealthUpdate()
	if helperFuncsDebug then debugPrint('Health changed and by: ' .. difference); end
	--[[
		Changes the health text, updates bar and sets value limits. 
		Also plays a sound when you lose health based on difference.
	]]--
	setTextString('healthTxt', math.floor(getProperty('healthBar.percent')) .. '/100');
	setProperty('healthBarBar.scale.x', (getHealth() / 2) * 3);
	if getProperty('healthBarBar.scale.x') > 3 then setProperty('healthBarBar.scale.x', 3); elseif getProperty('healthBarBar.scale.x') < 0 then setProperty('healthBarBar.scale.x', 0); end
	if difference > 0 then playSound('hurt', 1, 'hurtsnd'); end
end

--Text helper function so I don't paste the same shit over and over again.
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

function rgbToHex(r, g, b)
    local rgb = (r * 0x10000) + (g * 0x100) + b;
    return string.format("%x", rgb);
end

function makeLuaGraphic(tag, x, y, width, height, color)
	makeLuaSprite(tag, nil, x, y);
	makeGraphic(tag, width, height, color);
	addLuaSprite(tag, true);
end

function onEndSong()
	if not getPropertyFromClass('states.PlayState', 'chartingMode') then
		callMethodFromClass("backend.Highscore", "saveScore", {songName, getProperty('songScore'), rating});
		loadSong('Undertale Mix', 0);
		return Function_Stop;
	end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end