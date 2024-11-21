local path = 'stageassets/pellets/'
function onCreate()
	makeLuaSprite('floweyspot', path .. 'floweyspot', 324, 281);
	setProperty('floweyspot.antialiasing', false);
	scaleObject('floweyspot', 4, 4);
	addLuaSprite('floweyspot');
	
	makeLuaText('act?', "PLACE: TUTORIAL", 1280, -1000, 500);
    addLuaText('act?');
	setTextSize('act?', 40+10)
	--setTextColor('fakeSong', "FF0000");
	setTextFont('act?', "dtmmono.otf")
	--setTextBorder('fakeSong', 2, 'FFFFFF')
    setObjectCamera('act?', 'other');
	--setProperty('act?.alpha', 0)
	
	makeLuaText('realSong', "LOVE", 1280, 1000, 300); -- 100
    addLuaText('realSong');
	setTextSize('realSong', 60+10)
	--setTextColor('realSong', "FF0000");
	setTextFont('realSong', "dtmmono.otf")
	--setTextBorder('realSong', 2, 'FFFFFF')
    setObjectCamera('realSong', 'other');
	--setProperty('realSong.alpha', 0)
end

function onSongStart()
doTweenX('rushedones','realSong', 100, 1, 'quadInOut')
doTweenX('rushedones2','act?', 0, 1, 'quadInOut')
runTimer('yeahs', 2)
end

function onCreatePost() 
	triggerEvent('Camera Follow Pos', '645', '355'); 
	setProperty('cameraSpeed', 9 * math.pi);
	setProperty('camGame.alpha', 0.0001)
	
	--[[
	makeLuaSprite('floweyAnims', nil, 597, 225);
	setProperty('floweyAnims.antialiasing', false);
	loadGraphic('floweyAnims', path .. 'floweyanims', 21, 23);
	addAnimation('floweyAnims', 'hide', {0, 1, 2, 3, 4, 5}, 12, false);
	addAnimation('floweyAnims', 'idle', {0}, 0, false);
	scaleObject('floweyAnims', 4, 4);
	addLuaSprite('floweyAnims');
	]]
end

function onUpdate()
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	setProperty('scoreTxt.visible', false)
	setProperty('healthBar.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('camZooming', false)
	setProperty('showRating', false)
	setProperty('showComboNum', false)
	
		noteTweenAlpha("NoteOPP1", 0, 0, 0.0001, 'linear')
		noteTweenAlpha("NoteOPP2", 1, 0, 0.0001, 'linear')
		noteTweenAlpha("NoteOPP3", 2, 0, 0.0001, 'linear')
		noteTweenAlpha("NoteOPP4", 3, 0, 0.0001, 'linear')
	
		noteTweenX('bfTween1', 4, 95+325, 0.0001, 'sineInOut'); -- 90
        noteTweenX('bfTween2', 5, 205+325, 0.0001, 'sineInOut'); -- 205
        noteTweenX('bfTween3', 6, 315+325, 0.0001, 'sineInOut'); -- 313
        noteTweenX('bfTween4', 7, 425+325, 0.0001, 'sineInOut'); -- 425
		
	if getProperty('floweyAnims.animation.curAnim.name') == 'hide' and getProperty('floweyAnims.animation.curAnim.finished') then
		setProperty('floweyAnims.visible', false);
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'yeahs' then
	doTweenX('rushedones','realSong', -1000, 1, 'quadInOut')
	doTweenX('rushedones2','act?', 1000, 1, 'quadInOut')
	doTweenAlpha('fuck', 'camGame', 1, 3, 'linear')
	end
end

function onSectionHit()
	if curSection == 66 or curSection == 91 then
	setProperty('camGame.alpha', 0)
	
	elseif curSection == 67 then
	setProperty('camGame.alpha', 1)
	end
end

function onBeatHit()
	if curBeat == 366 then
	doTweenAlpha('fuck man', 'camHUD', 0, 1, 'linear')
	end
end