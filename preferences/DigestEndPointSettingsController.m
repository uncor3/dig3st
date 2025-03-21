// https://github.com/NoisyFlake/Velvet2/blob/master/preferences/Velvet2SettingsController.m
#import "../headers/HeadersPreferences.h"

@implementation DigestEndpointSettingsController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [NSClassFromString(@"DigestPrefsManager") sharedInstance];
		self.logger =[NSClassFromString(@"DigestLogger") sharedInstance];
    }
    return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
	    _specifiers = [self visibleSpecifiersFromPlist:@"Endpoint"];
		if (self.titleKey) {
			self.title = self.titleKey;
		}
	}

	return _specifiers;
}

-(void)showController:(id)controller {
	return [super showController:controller]; 
}

-(void)viewDidLayoutSubviews {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
	[super viewDidLayoutSubviews];
}
-(void)save {
	@try {
		BOOL isOkayToSave = YES;
		NSMutableDictionary *endpoint = [NSMutableDictionary new];
		for (PSSpecifier *specifier in self.specifiers) {
			//skip group cell
			if ([[specifier.properties valueForKey:@"cell"] isEqual:@"PSGroupCell"] ) continue;
			
			[self.logger log:[NSString stringWithFormat:@"specifier: %@", specifier.properties] level:LOGLEVEL_VERBOSE];
			PSEditableTableCell *cell = [specifier.properties valueForKey:@"cellObject"];
			UITextField *textField = [cell valueForKey:@"textField"]; 
			if (textField) {
				NSString *inputText = textField.text;
				if (!inputText || inputText.length == 0) {
					isOkayToSave = NO;
					break;
				}

				endpoint[specifier.properties[@"key"]] = inputText;
				[self.logger log:[NSString stringWithFormat:@"TextField Text: %@", inputText] level:LOGLEVEL_VERBOSE];
			} else {
				NSLog(@"Failed to access textField.");
			}
		}
		if (!isOkayToSave) return Alert(@"Error", @"Please fill in all fields.",self);

		DigestPrefsManager *manager = [NSClassFromString(@"DigestPrefsManager") sharedInstance];
		if (self.endpoint) {
			[self.logger log:[NSString stringWithFormat:@"Updating endpoint: %@", endpoint] level:LOGLEVEL_INFO];
			endpoint[@"uuid"] = self.endpoint[@"uuid"];
			//find the endpoint and update it
			NSMutableArray *mutableEndpoints = [[manager objectForKey:@"endpoints"] mutableCopy];
			for (int i = 0; i < mutableEndpoints.count; i++) {
				if ([mutableEndpoints[i][@"uuid"] isEqualToString:endpoint[@"uuid"]]) {
					[mutableEndpoints replaceObjectAtIndex:i withObject:endpoint];
					[manager setObject:mutableEndpoints forKey:@"endpoints"];
					break;
				}
			}
			//update the ui for preferences
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.uncore.dig3st/endpointUpdate" object:nil];
			//update the openai endpoint
        	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.uncore.dig3st/preferences.changed", NULL, NULL, true);

		    [self.navigationController popViewControllerAnimated:YES];
			return;
		}
		NSString *uuid = [[NSUUID UUID] UUIDString];
		endpoint[@"uuid"] = uuid;
        NSMutableArray *endpoints = [[manager objectForKey:@"endpoints"] mutableCopy];
		[self.logger log:[NSString stringWithFormat:@"Adding endpoint: %@", endpoint] level:LOGLEVEL_INFO];
		[endpoints addObject:endpoint];
		[manager setObject:endpoints forKey:@"endpoints"];
		[self.logger log:[NSString stringWithFormat:@"Final endpoints: %@", endpoints] level:LOGLEVEL_VERBOSE];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.uncore.dig3st/endpointUpdate" object:nil];
    	[self.navigationController popViewControllerAnimated:YES];
	}@catch(NSException *e) {
		NSLog(@"Error: %@", e);
		Alert(@"Error", @"An error occurred while saving.",self);
	}
}

-(id)readPreferenceValue:(PSSpecifier*)specifier {
	if (!self.endpoint) return nil;

	return self.endpoint[specifier.properties[@"key"]];
}

- (NSMutableArray*)visibleSpecifiersFromPlist:(NSString*)plist {
	return [self loadSpecifiersFromPlistName:plist target:self];
}
@end