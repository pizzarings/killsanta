#import "MenuLayer.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "SharedData.h"

@implementation MenuLayer

+ (CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild: [MenuLayer node]];

	return scene;
}

SharedData *data;

CCMenuItem *musicOnItem;
CCMenuItem *musicOffItem;

- (id) init
{
	if (self = [super init])
    {
        data = [SharedData sharedInstance];

        CGSize size = [[CCDirector sharedDirector] winSize];

        CCSprite *backgroundMenu = [CCSprite spriteWithFile:@"menu.png"];
        
        if (IS_IPHONE_5)
            backgroundMenu = [CCSprite spriteWithFile:@"menu-5.png"];
        
        backgroundMenu.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:backgroundMenu];

        // Music
        musicOnItem = [CCMenuItemImage itemWithNormalImage:@"MusicOn.png" selectedImage:@"MusicOn.png" target:nil selector:nil];
        musicOffItem = [CCMenuItemImage itemWithNormalImage:@"MusicOff.png" selectedImage:@"MusicOff.png" target:nil selector:nil];
        CCMenuItemToggle *musicItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicButtonTapped:) items:musicOnItem, musicOffItem, nil];
        CCMenu *musicButton = [CCMenu menuWithItems:musicItem, nil];
        musicButton.position = CGPointMake(size.width - musicOnItem.boundingBox.size.width/2 - 5, size.height - musicOnItem.boundingBox.size.height/2 - 5);
        [self addChild:musicButton];
        
        if ([data.settings objectForKey:@"Music"] == nil)
            [data.settings setBool:YES forKey:@"Music"];
        
        if (![data.settings boolForKey:@"Music"])
        {
            [musicItem setSelectedIndex:1];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:BackgroundMusic loop:TRUE];
            [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        }
        else
            if ([data.settings boolForKey:@"Music"] && ![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:BackgroundMusic loop:TRUE];


        // Menu
        CCLabelTTF *labelPlay = [CCLabelTTF labelWithString:@"Play" fontName:FontName fontSize:50];
        CCMenuItem *itemPlay = [CCMenuItemFont itemWithLabel:labelPlay block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
		}];
        
        CCMenu *menu = [CCMenu menuWithItems:itemPlay, nil];
		[menu setPosition:ccp(size.width/2, size.height/2 + musicOnItem.boundingBox.size.height)];
        
        [self addChild:menu];


        // Credits
        labelScrollingCredits = [CCLabelTTF labelWithString:@"Kill Santa - Xmas Rome Hackathon Project by PizzaRings - Splash and Icon by Emi - Graphics and Music by Google" fontName:FontName fontSize:16];
        labelScrollingCredits.color = ccc3(185, 211, 238);
        
        labelScrollingCredits.position = CGPointMake(size.width + labelScrollingCredits.boundingBox.size.width/2, labelScrollingCredits.boundingBox.size.height - 10);
        
        [self addChild:labelScrollingCredits];
        [self startInfiniteScrolling:labelScrollingCredits.position];
    }
    
    return self;
}

- (void) musicButtonTapped:(id)sender
{
    if (((CCMenuItemToggle *)sender).selectedItem == musicOnItem)
    {
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [data.settings setBool:YES forKey:@"Music"];
    }
    else
    {
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [data.settings setBool:NO forKey:@"Music"];
    }
}

- (void) startInfiniteScrolling:(CGPoint)strartingPoint
{
    CGPoint targetPos = CGPointMake(-labelScrollingCredits.boundingBox.size.width, labelScrollingCredits.boundingBox.size.height);
    CCSequence *seq = [CCSequence actions:[CCMoveTo actionWithDuration:ccpDistance(strartingPoint, targetPos) / 50.0 position:targetPos], [CCCallFuncN actionWithTarget:self selector:@selector(movementComplete:)], nil];
    seq.tag = 999;
    [labelScrollingCredits runAction:seq];
}

- (void) movementComplete:(id) sender
{
    labelScrollingCredits.position = CGPointMake([[CCDirector sharedDirector] winSize].width + labelScrollingCredits.boundingBox.size.width/2, labelScrollingCredits.boundingBox.size.height);
	[self startInfiniteScrolling:labelScrollingCredits.position];
}

@end
