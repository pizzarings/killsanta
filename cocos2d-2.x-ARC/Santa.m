#import "Santa.h"

@implementation Santa

@synthesize inizialPosition, currentPosition, targetPosition, points;

-(id)init
{
    self = [super init];
    if (self)
    {
        inizialPosition.x = 0;
        inizialPosition.y = 0;
        currentPosition.x = 0;
        currentPosition.y = 0;
        targetPosition.x = 0;
        targetPosition.y = 0;
        points = 0;
	}
    return self;
}

@end
