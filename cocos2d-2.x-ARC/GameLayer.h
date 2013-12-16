#import <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>

@interface GameLayer : CCLayer
{
    UIDeviceOrientation orientation;
    int currentScore;
    CCLabelTTF *lblCurrentScore;
    int timerCount;
    CCLabelTTF *lblTimer;
    CCLabelTTF *lblHighScore;
}

@property CCSpriteBatchNode *santaBatchNode;

+ (CCScene *) scene;

@end

