// https://github.com/NoisyFlake/Velvet2/blob/master/preferences/Velvet2SettingsController.m
#import "../headers/HeadersPreferences.h"
#import <Preferences/PSListItemsController.h>

@interface PSSpecifier (Digest)
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSDictionary *titleDictionary;
@property (nonatomic, strong) NSDictionary *shortTitleDictionary;
@end

@implementation DigestSettingsController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"com.uncore.dig3st/endpointUpdate" object:nil];
    }
    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
	    _specifiers = [self getSpecifiers];
	}
	return _specifiers;
}

-(void)update {
	// _specifiers = [self getSpecifiers];
	[self reloadSpecifiers];
}

-(NSMutableArray*)getSpecifiers {
	NSMutableArray *specifiers = [self visibleSpecifiersFromPlist:@"Settings"];
	return specifiers;
}

- (void)dealloc { 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.uncore.dig3st/endpointUpdate" object:nil];
}

-(void)showController:(id)controller {
	return [super showController:controller]; 
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
	DigestPrefsManager *manager = [NSClassFromString(@"DigestPrefsManager") sharedInstance];
	return [manager objectForKey:specifier.properties[@"key"]];
}

- (NSMutableArray*)visibleSpecifiersFromPlist:(NSString*)plist {
	return [self loadSpecifiersFromPlistName:plist target:self];
}

-(void)yt {
	NSString *videoID = @"Dm8FfbfD5q0";
	NSString *youtubeURLString = [NSString stringWithFormat:@"youtube://www.youtube.com/watch?v=%@", videoID];
	NSURL *youtubeURL = [NSURL URLWithString:youtubeURLString];

	if ([[UIApplication sharedApplication] canOpenURL:youtubeURL]) {
		[[UIApplication sharedApplication] openURL:youtubeURL options:@{} completionHandler:nil];
	} else {
		// Open in Safari if YouTube app is not installed
		NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID]];
		[[UIApplication sharedApplication] openURL:webURL options:@{} completionHandler:nil];
	}
}

-(void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://uncore.me/donate"] options:@{} completionHandler:nil];
}
@end