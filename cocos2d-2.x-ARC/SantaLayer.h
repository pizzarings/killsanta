#import <CoreMotion/CoreMotion.h>

@class Santa;

@interface SantaLayer : CCLayer
{
    CMMotionManager *motionManager;
}

@property CCSpriteBatchNode *santaBatchNode;
@property Santa *santa;
@property CCSprite *gift;

+ (CCScene *) scene;
- (void) dropGift:(CCSprite *)santaSprite;


@end
