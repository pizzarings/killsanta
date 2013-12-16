@interface SharedData : NSObject
{
    NSUserDefaults *settings;
    BOOL isPaused;
}

@property NSUserDefaults *settings;
@property BOOL isPaused;
@property BOOL ruotato;

+ (SharedData*) sharedInstance;

@end
