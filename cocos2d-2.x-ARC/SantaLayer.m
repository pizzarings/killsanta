#import "SantaLayer.h"
#import "Santa.h"
#import "SharedData.h"

@implementation SantaLayer

@synthesize santa, santaBatchNode, gift;

SharedData *data;

+ (CCScene *) scene
{
	CCScene *scene = [CCScene node];
	SantaLayer *layer = [SantaLayer node];
	[scene addChild: layer];
	return scene;
}

- (id) init
{
	if (self = [super init])
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Load dello sprite batch node dove sono presenti gli sprite di Babbo Natale
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"santaSprite.plist"];
        santaBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"santaSprite.png"];
        [self addChild:santaBatchNode];
        
        // Load di tutti gli sprite che compongono Babbo Natale
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for (int i = 1; i <= 4; ++i)
            [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"animation0%d.png", i]]];
        
        // Load del primo sprite di Babbo Natale e posizione a schermo
        santa = [Santa spriteWithSpriteFrameName:@"animation01.png"];
        
        // Creazione dell'animazione di Babbo Natale che corre con la slitta
        CCAnimation * animation = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.2f];
        CCAction *runForever = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:animation]];
        [santa runAction:runForever];
        
        // Set della posizione a schermo
        santa.position = ccp(size.width/2, size.height/2);
        santa.inizialPosition = santa.position;
        santa.currentPosition = santa.position;
        santa.tag = SantaTag;
        [santaBatchNode addChild:santa z:SantaIndex tag:667];
        
        // Inizializzazione giroscopio
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        if (motionManager.isDeviceMotionAvailable)
            [motionManager startDeviceMotionUpdates];
        
        data = [SharedData sharedInstance];
        data.ruotato = FALSE;
        
        [self addMovement:santa];
        [self scheduleUpdate];
	}
	return self;
}

- (void) update:(ccTime)delta
{
    #if !(TARGET_IPHONE_SIMULATOR)
    CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    float currentYaw = CC_RADIANS_TO_DEGREES(currentAttitude.yaw);
    float currentRoll = ABS(CC_RADIANS_TO_DEGREES(currentAttitude.roll));
    
    if (data.ruotato)
    {
        if (currentYaw > 0)
            currentYaw = (currentYaw - LayerRotation);
        else
            currentYaw = (currentYaw + LayerRotation);
    }
    
    [self setPosition:CGPointMake((currentYaw * kXPositionMultiplier), 0 - ((currentRoll - 54) * kXPositionMultiplier))];
    #endif
}

- (void) addMovement:(Santa *)santa2update
{
    santa2update.targetPosition = [self generateRandomPosition];
    float duration = ccpDistance(santa2update.inizialPosition, santa2update.targetPosition) / 180; //speed;
    
    CCMoveTo* move = [CCMoveTo actionWithDuration:duration position:santa2update.targetPosition];
    CCCallFuncN *func = [CCCallFuncN actionWithTarget:self selector:@selector(movementComplete:)];
    CCSequence *seq = [CCSequence actions:move, func, nil];
    seq.tag = santa2update.tag;
    
    [self flipOrientation:santa2update];
    
    [santa2update runAction:seq];
}

- (void) movementComplete:(id) sender
{
    Santa *santa2update = ((Santa *)sender);

    santa2update.inizialPosition = santa2update.targetPosition;
    [self addMovement:sender];
}

- (void) dropGift:(CCSprite *)santaSprite
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    gift = [CCSprite spriteWithFile:@"greengift.png"];
    gift.visible = TRUE;
    gift.position =santaSprite.position;
    
    CCAction *jumpTo = [CCJumpTo actionWithDuration:3 position:ccp(size.width, 0) height:30 jumps:1];
    CCAction *fadeOut = [CCFadeTo actionWithDuration:3 opacity:0];
    
    gift.tag = 23;
    [gift runAction:jumpTo];
    [gift runAction:fadeOut];
    [self addChild:gift z:0];
}

- (CGPoint)generateRandomPosition
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    int x = 0;
    int y = 0;
    
    int pos = arc4random() % 2;
    if (pos > 0)
    {
        x = arc4random() % ((int)size.width * GameAreaMultiplier);
    }
    else
    {
        x = -arc4random() % ((int)size.width * GameAreaMultiplier);
    }
    pos = arc4random() % 2;
    if (pos > 0)
    {
        y = arc4random() % ((int)size.height * GameAreaMultiplier);
    }
    else
    {
        y = -arc4random() % ((int)size.height * GameAreaMultiplier);
    }
    
    return CGPointMake(x, y);
}

- (void) flipOrientation:(Santa *)santa2update
{
    CGPoint pnormal = ccpSub(santa2update.targetPosition, santa2update.inizialPosition);
    CGFloat angle = [self CGPointToDegree: pnormal];
    santa2update.rotation = angle;

    CCLOG(@"%@",[NSString stringWithFormat:@"Angle: %f", angle]);
    
    santa2update.flipX = angle < 0 ? TRUE : FALSE;
}

- (CGFloat) CGPointToDegree:(CGPoint) point
{
    // Provides a directional bearing from (0,0) to the given point.
    // standard cartesian plain coords: X goes up, Y goes right
    // result returns degrees, -180 to 180 ish: 0 degrees = up, -90 = left, 90 = right
    CGFloat bearingRadians = atan2f(point.x, point.y);
    CGFloat bearingDegrees = bearingRadians * (180. / M_PI);
    return bearingDegrees;
}

@end
