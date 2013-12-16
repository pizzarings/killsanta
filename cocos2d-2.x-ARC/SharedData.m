#import "SharedData.h"

@implementation SharedData

@synthesize settings;
@synthesize isPaused;
@synthesize ruotato;

+ (SharedData*) sharedInstance
{
    static SharedData *sharedData = nil;
    
    if (sharedData == nil)
        sharedData = [[[self class] alloc] init];
    
    return sharedData;
}

- (id) init
{
    if (self = [super init])
        settings = [NSUserDefaults standardUserDefaults];

    return self;
}

@end