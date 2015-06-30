
//Initialize the variables.
bool enabled;
NSString *someString;

static void loadPreferences() {
    CFPreferencesAppSynchronize(CFSTR("com.greeny.censorednotifications"));
    //In this case, you get the value for the key "enabled"
    //you could do the same thing for any other value, just cast it to id and use the conversion methods
    //if the value doesn't exist (i.e. the user hasn't changed their preferences), it is set to the value after the "?:" (in this case, YES and @"default", respectively
    enabled = [(id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.greeny.censorednotifications")) boolValue];
    someString = [(id)CFPreferencesCopyAppValue(CFSTR("someString"), CFSTR("com.greeny.censorednotifications")) stringValue];
}

%hook BBBulletin
- (void)setSectionID:(NSString*)arg1
{
    if([NSString isEqualToString:@"com.apple.MobileSMS"]){
        [self setMessage: @"New Message"];
    }
        %orig(arg1);
}
%end
%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("com.greeny.censorednotifications/prefsChanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPreferences();
}