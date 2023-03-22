package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import shaders.ColorMaskShader;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class GalleryArtState extends MusicBeatState
{
	var curSelected:Int = 0;

	var backdrop:FlxBackdrop;
	var gradient:FlxSprite;
	var switchState:FlxSprite;
	
	var setaEsquerda:FlxSprite;
	var setaDireita:FlxSprite;

	var galleryData:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/galleryData', 'preload'));
	var artworkData:Array<String> = [];
	var authorData:Array<String> = [];
	var urlData:Array<String> = [];

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Viewing the Art Gallery", null);
		#end

		FlxG.sound.playMusic(Paths.music('sayoc'));
		Conductor.changeBPM(110);

		for (i in 0...galleryData.length)
		{
			if (galleryData[i].startsWith('//'))
				continue;

			var data:Array<String> = galleryData[i].split('::');

			artworkData.push(data[0]);
			authorData.push(data[1].replace("\\n", "\n"));
			urlData.push(data[2]);
		}

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-16, 0);
		backdrop.scale.set(0.5, 0.5);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFF780D48, 0xFF87235D);
		add(backdrop);

		gradient = new FlxSprite(0, 0).loadGraphic(Paths.image('gradient', 'preload'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.color = 0xFF46114A;
		add(gradient);
		
		artwork = new FlxSprite(0, 0).loadGraphic(Paths.image('Fumo', 'preload'));
		artwork.antialiasing = SaveData.globalAntialiasing;
		add(artwork);

		switchState = new FlxSprite(0, 0).loadGraphic(Paths.image('sticker', 'preload'));
		switchState.setGraphicSize(Std.int(switchState.width * 0.5));
		switchState.updateHitbox();
		switchState.x = (FlxG.width - switchState.width) - 10;
		switchState.y += 10;
		switchState.antialiasing = SaveData.globalAntialiasing;
		add(switchState);

		authorText = new FlxText(0, 0, 0, "", 8);
		authorText.setFormat(LangUtil.getFont('aller'), 29, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		authorText.y += LangUtil.getFontOffset('aller');
		authorText.antialiasing = SaveData.globalAntialiasing;
		add(authorText);
		
		setaEsquerda = new FlxSprite(50,0);
		setaEsquerda.loadGraphic(Paths.image('seta','doki');
		setaEsquerda.antialiasing = SaveData.globalAntialiasing;
		setaEsquerda.setGraphicSize(std.Int(setaEsquerda.width * 1));
		setaEsquerda.updateHitbox();
		setaEsquerda.screenCenter(Y);
		add(setaEsquerda);
		
		setaDireita = new FlxSprite(0,0);
		setaDireita.loadGraphic(Paths.image('seta','doki');
		setaDireita.antialiasing = SaveData.globalAntialiasing;
		setaDireita.setGraphicSize(std.Int(setaEsquerda.width * 1));
		setaDireita.x = FlxG.width - setaDireita.width - 50;
		setaDireita.flipX = true;
		setaDireita.updateHitbox();
		setaDireita.screenCenter(Y);
		add(setaDireita);

		changeItem();

		super.create();
	}

	var dontSpam:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (controls.BACK #if android || FlxG.android.justReleased.BACK #end)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.LEFT_P || BSLTouchUtils.aperta(setaEsquerda,0)=='primeiro')
			changeItem(-1);
		else if (controls.RIGHT_P || BSLTouchUtils.aperta(setaDireita,0)=='primeiro')
			changeItem(1);

		if (controls.ACCEPT || (BSLTouchUtils.aperta(artwork,0) && artworkData[curSelected].contains('antipathy'))
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			CoolUtil.openURL(urlData[curSelected]);
		}

		if (FlxG.mouse.overlaps(artwork) && FlxG.mouse.pressed && artworkData[curSelected].contains('antipathy') && !dontSpam)
		{
			FlxG.camera.fade(FlxColor.WHITE, 1, true, true);
			FlxG.sound.play(Paths.sound('antipathyUnlock'));
			SaveData.unlockAntipathyCostume = true;
			dontSpam = true;
		}

		if (FlxG.keys.justPressed.S || BSLTouchUtils.aperta(switchState, 0);
			MusicBeatState.switchState(new GalleryStickerState());

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (curSelected >= galleryData.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = galleryData.length - 1;

		artwork.loadGraphic(Paths.image('gallery/' + artworkData[curSelected], 'preload'));
		artwork.setGraphicSize(0, Std.int(FlxG.height * 0.8));
		artwork.updateHitbox();

		if (artwork.width > FlxG.width)
			artwork.setGraphicSize(Std.int(FlxG.width * 0.9));

		artwork.updateHitbox();
		artwork.screenCenter();
		artwork.y -= 30;

		authorText.text = authorData[curSelected] + '\n';
		authorText.screenCenter();
		authorText.y = artwork.y + artwork.height + 15;

		dontSpam = false;
	}

	override function beatHit()
	{
		super.beatHit();
	}
}
