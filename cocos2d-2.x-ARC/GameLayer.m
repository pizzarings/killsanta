#import "GameLayer.h"
#import "MenuLayer.h"
#import "SantaLayer.h"
#import "Santa.h"
#import "SimpleAudioEngine.h"
#import "SharedData.h"

@implementation GameLayer

@synthesize santaBatchNode;

SharedData *data;

CCMenuItem *musicOnItem;
CCMenuItem *musicOffItem;
CCMenuItemToggle *timerPauseItem;

CCMenu *pauseButton;

+ (CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameLayer *gameLayer = [GameLayer node];
	SantaLayer *santaLayer = [SantaLayer node];
    santaLayer.tag = SantaLayerTag;
    
	[scene addChild: santaLayer];
    [scene addChild: gameLayer];
    
	return scene;
}

- (id) init
{
	if (self = [super init])
    {
        data = [SharedData sharedInstance];
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // START MUSIC BLOCK
        musicOnItem = [CCMenuItemImage itemWithNormalImage:@"MusicOn.png" selectedImage:@"MusicOn.png" target:nil selector:nil];
        musicOffItem = [CCMenuItemImage itemWithNormalImage:@"MusicOff.png" selectedImage:@"MusicOff.png" target:nil selector:nil];
        CCMenuItemToggle *musicItem = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicButtonTapped:) items:musicOnItem, musicOffItem, nil];
        CCMenu *musicButton = [CCMenu menuWithItems:musicItem, nil];
        musicButton.position = CGPointMake(size.width - musicOnItem.boundingBox.size.width/2, size.height - musicOnItem.boundingBox.size.height/2);
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
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dropGift.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"missedSanta.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickGift.caf"];
        // END MUSIC BLOCK
        
        //Load dello sprite batch node dove sono presenti gli sprite di Babbo Natale
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"santaSprite.plist"];
        santaBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"santaSprite.png"];
        [self addChild:santaBatchNode];
        
        //Load trarget
        CCSprite *target = [CCSprite spriteWithFile:@"snowflake.png"];
        target.position = ccp(size.width/2, size.height/2);
        target.tag = TargetTag;
        [self addChild:target];
        
        //HighScore
        if ([data.settings objectForKey:@"HighScore"] == nil)
            [data.settings setInteger:0 forKey:@"HighScore"];
        int highScore = [data.settings integerForKey:@"HighScore"];
        lblHighScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HIGH SCORE: %d", highScore] fontName:FontName fontSize:12];
        lblHighScore.position = ccp(size.width/2, size.height - (lblHighScore.boundingBox.size.height/2));
        [self addChild:lblHighScore];
        
        //CurrentScore
        currentScore = 0;
        lblCurrentScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SCORE: %d", currentScore] fontName:FontName fontSize:12];
        lblCurrentScore.position = ccp(lblCurrentScore.boundingBox.size.width/2, size.height - (lblCurrentScore.boundingBox.size.height/2));
        [self addChild:lblCurrentScore];
        
        // START TIMER BLOCK
        timerCount = timerCountDown;
        lblTimer = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"TIME: %01i:%02i", (timerCount/60)%60, timerCount%60]  fontName:FontName fontSize:12];
        lblTimer.position = ccp(lblTimer.boundingBox.size.width/2, lblCurrentScore.position.y - lblTimer.boundingBox.size.height);
        [self addChild:lblTimer];
        // END TIMER BLOCK
        
        // Tell the UIDevice to send notifications when the orientation changes
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

        [self schedule:@selector(santaIndicator:) interval:1/60.0];
        
        self.isTouchEnabled = YES;
        
        [self schedule:@selector(advanceTimer:) interval:1];
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

- (void) advanceTimer:(ccTime)delta
{
    timerCount--;
    [lblTimer setString:[NSString stringWithFormat:@"TIME: %01i:%02i", (timerCount/60)%60, timerCount%60]];
    
    if (timerCount <= 0)
    {
        [self unschedule:@selector(advanceTimer:)];
        [self unschedule:@selector(santaIndicator:)];

        CCSprite *indicator = (CCSprite *)[self getChildByTag:667 + IndicatorTag];
        if (indicator != nil)
        {
            indicator.visible = FALSE;
            [self removeChildByTag:667 + IndicatorTag cleanup:NO];
        }
        
        int currentHighScore = [data.settings integerForKey:@"HighScore"];
        if (currentScore > currentHighScore)
        {
            [data.settings setInteger:currentScore forKey:@"HighScore"];
            [lblHighScore setString:[NSString stringWithFormat:@"HIGH SCORE: %d", currentHighScore]];
        }
        
        CCLabelTTF *labelPlay = [CCLabelTTF labelWithString:@"Try Again" fontName:FontName fontSize:18];
        CCMenuItem *itemPlay = [CCMenuItemFont itemWithLabel:labelPlay block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
        }];
        
        CCLabelTTF *labelMenu = [CCLabelTTF labelWithString:@"Back to Menu" fontName:FontName fontSize:18];
        CCMenuItem *itemMenu = [CCMenuItemFont itemWithLabel:labelMenu block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[MenuLayer scene]];
		}];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCMenu *menu = [CCMenu menuWithItems:itemPlay, itemMenu, nil];
        [menu alignItemsVerticallyWithPadding:26];
		menu.position = ccp(size.width/2, size.height/4);
        
        [self addChild:menu];
    }
}

- (void) onExit
{
    [super onExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![[CCDirector sharedDirector] isPaused] && timerCount > 0)
    {
        // Calcolo la differenza tra il layer dove c'è il mirino e quello dove c'è babbo natale si sposta in base al giroscopio
        CGPoint diffLayer = ccpSub(self.position, ([[[CCDirector sharedDirector] runningScene] getChildByTag:SantaLayerTag]).position);
                
        SantaLayer *santaLayer = ((SantaLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:SantaLayerTag]);
        Santa *santa = santaLayer.santa;
        CCSprite *gift = santaLayer.gift;
        
        CCSprite *target = (CCSprite *)[self getChildByTag:TargetTag];
        float scopeImageSize = target.boundingBox.size.width;
        float scopeCollisionRadius = scopeImageSize * SantaCollisionRadius;
        
        if (santa != nil)
        {
            float santaImageSize = santa.texture.contentSize.width;
            float santaCollisionRadius = santaImageSize * SantaCollisionRadius;
            float maxSantaCollisionDistance = scopeCollisionRadius + santaCollisionRadius;
            float santaDistance = ccpDistance(target.position, ccpSub(santa.position, diffLayer));
            
            if (santaDistance < maxSantaCollisionDistance)
            {
                // Colpito Babbo Natale
                CCLOG(@"Babbo Natale colpito!");
                [[SimpleAudioEngine sharedEngine] playEffect:@"dropGift.caf"];
                [santaLayer dropGift:santa];
            }
            else
                [[SimpleAudioEngine sharedEngine] playEffect:@"missedSanta.caf"];
        }
        
        if (gift != nil)
        {
            float giftImageSize = gift.texture.contentSize.width;
            float giftCollisionRadius = giftImageSize * GiftCollisionRadius;
            float maxGiftCollisionDistance = scopeCollisionRadius + giftCollisionRadius;
            float giftDistance = ccpDistance(target.position, ccpSub(gift.position, diffLayer));
            
            if (giftDistance < maxGiftCollisionDistance)
            {
                // Colpito i doni
                CCLOG(@"Dono colpito!");
                gift.visible = FALSE;
                currentScore += [self getRandomPoints];
                [lblCurrentScore setString:[NSString stringWithFormat:@"SCORE: %d", currentScore]];
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickGift.caf"];
            }
        }
    }
}

- (int) getRandomPoints
{
    return (arc4random() % 4) + 1;
}

- (void) santaIndicator:(ccTime)delta
{
    CGSize size = [CCDirector sharedDirector].winSize;
    CGPoint diffLayer = ccpSub(self.position, ([(SantaLayer *)[[CCDirector sharedDirector] runningScene] getChildByTag:SantaLayerTag]).position);
    
    Santa *santa = ((SantaLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:SantaLayerTag]).santa;
    
    BOOL indicatorToAdd = FALSE;
    CGPoint diffPosition = ccpSub(santa.position, diffLayer);
    
    CCSprite *indicator = (CCSprite *)[self getChildByTag:santa.tag + IndicatorTag];
    if (indicator == nil)
    {
        indicator = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
        indicatorToAdd = TRUE;
    }
    
    int tagSantaIndicator = santa.tag + IndicatorTag;
    
    CGPoint santaIndicatorPosition = CGPointMake(0, 0);
    BOOL showX = TRUE;
    BOOL showY = TRUE;
    
    if (diffPosition.x < 0)
    {
        santaIndicatorPosition.x = SantaIndicatorPosition;
        
        if (diffPosition.y > SantaIndicatorPosition && diffPosition.y < (size.height - SantaIndicatorPosition))
            indicator.rotation = 270;
        else if (diffPosition.y > (size.height - SantaIndicatorPosition))
            indicator.rotation = 315;
        else
            indicator.rotation = 225;
    }
    else if (diffPosition.x > size.width)
    {
        santaIndicatorPosition.x = size.width - SantaIndicatorPosition;
        
        if (diffPosition.y > SantaIndicatorPosition && diffPosition.y < (size.height - SantaIndicatorPosition))
            indicator.rotation = 90;
        else if (diffPosition.y > (size.height - SantaIndicatorPosition))
            indicator.rotation = 45;
        else
            indicator.rotation = 135;
    }
    else
    {
        santaIndicatorPosition.x = diffPosition.x - SantaIndicatorPosition;
        showX = FALSE;
    }
    
    if (diffPosition.y < 0)
    {
        santaIndicatorPosition.y = SantaIndicatorPosition;
        
        if (diffPosition.x > SantaIndicatorPosition && diffPosition.x < (size.width - SantaIndicatorPosition))
            indicator.rotation = 180;
        else if (diffPosition.x > (size.width - SantaIndicatorPosition))
            indicator.rotation = 135;
        else
            indicator.rotation = 225;
    }
    else if (diffPosition.y > size.height)
    {
        santaIndicatorPosition.y = size.height - SantaIndicatorPosition;
        
        if (diffPosition.x > SantaIndicatorPosition && diffPosition.x < (size.width - SantaIndicatorPosition))
            indicator.rotation = 0;
        else if (diffPosition.x > (size.height - SantaIndicatorPosition))
            indicator.rotation = 45;
        else
            indicator.rotation = 315;
    }
    else
    {
        santaIndicatorPosition.y = diffPosition.y - SantaIndicatorPosition;
        showY = FALSE;
    }
    
    if (showX == FALSE && showY == FALSE)
    {
        // Rimuovo l'indicatore associato a babbo natale perchè entrato nell'area visibile dello schermo
        if (indicatorToAdd == FALSE)
            [self removeChildByTag:tagSantaIndicator cleanup:NO];
    }
    else
    {
        // Imposto la posizione dell'indicatore e nel caso sia nuovo l'aggiunto alla scena
        indicator.position = santaIndicatorPosition;
        if (indicatorToAdd)
            [self addChild:indicator z:IndicatorIndex tag:tagSantaIndicator];
    }
}

- (void) orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    switch (currentOrientation)
    {
        case UIDeviceOrientationUnknown:
            #if !(TARGET_IPHONE_SIMULATOR)
            CCLOG(@"UIDeviceOrientationUnknown");
            [[CCDirector sharedDirector] stopAnimation];
            [[CCDirector sharedDirector] pause];
            #endif
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            CCLOG(@"UIDeviceOrientationLandscape");
            data.ruotato = currentOrientation != orientation;
            if (!data.isPaused)
            {
                [[CCDirector sharedDirector] stopAnimation]; // Call this to make sure you don't start a second display link!
                [[CCDirector sharedDirector] resume];
                [[CCDirector sharedDirector] startAnimation];
            }
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
            CCLOG(@"UIDeviceOrientationPortrait");
        default:
            break;
    }
}

@end
