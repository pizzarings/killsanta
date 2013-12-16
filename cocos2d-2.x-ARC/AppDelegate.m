#import "cocos2d.h"
#import "AppDelegate.h"
#import "MenuLayer.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@implementation AppController

@synthesize window = window_, navController = navController_, director = director_;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:BackgroundMusic];

	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	[director_ setDisplayStats:NO];

	[director_ setAnimationInterval:1.0/60];

	[director_ setView:glView];

    //RGB (87, 135, 187, 0)
    glClearColor(0.3411, 0.5294, 0.7333, 0);

	[director_ setDelegate:self];

	[director_ setProjection:kCCDirectorProjection2D];

	if (![director_ enableRetinaDisplay:YES])
		CCLOG(@"Retina Display Not supported");

	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

    [window_ setRootViewController:navController_];

	[window_ makeKeyAndVisible];

	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	[[CCFileUtils sharedFileUtils] setiPhoneRetinaDisplaySuffix:@"-hd"]; // Default on iPhone RetinaDisplay is "-hd"
	[[CCFileUtils sharedFileUtils] setiPadSuffix:@"-ipad"]; // Default on iPad is "" (empty string)
	[[CCFileUtils sharedFileUtils] setiPadRetinaDisplaySuffix:@"-ipadhd"]; // Default on iPad RetinaDisplay is "-ipadhd"

	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	[director_ pushScene:[MenuLayer scene]];

	return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	if ([navController_ visibleViewController] == director_)
		[director_ pause];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	if([navController_ visibleViewController] == director_)
		[director_ resume];
}

- (void) applicationDidEnterBackground:(UIApplication*)application
{
	if([navController_ visibleViewController] == director_)
		[director_ stopAnimation];
}

- (void) applicationWillEnterForeground:(UIApplication*)application
{
	if([navController_ visibleViewController] == director_)
		[director_ startAnimation];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
