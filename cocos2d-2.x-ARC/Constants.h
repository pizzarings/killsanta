#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#define SantaLayerTag 999
#define TargetTag 556
#define kXPositionMultiplier 5
#define LayerRotation 180
#define GameAreaMultiplier 2
#define SantaIndex 1
#define SantaTag 666
#define IndicatorTag 200
#define SantaIndicatorPosition 16
#define IndicatorIndex 14
#define SantaCollisionRadius 0.2f
#define GiftCollisionRadius 0.7f

// http://www.fontspace.com/codeman38/press-start-2p
#define FontName @"PressStart2P"

#define BackgroundMusic @"BackgroundMusic.mp3"

#define timerCountDown 60 //secs
