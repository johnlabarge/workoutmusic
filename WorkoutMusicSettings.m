//
//  WorkoutMusicSettings.m
//  WorkoutMusic
//
//  Created by La Barge, John on 5/1/13.
//  Copyright (c) 2013 John La Barge. All rights reserved.
//

#import "WorkoutMusicSettings.h"

@implementation WorkoutMusicSettings

// Get the shared instance and create it if necessary.
static WorkoutMusicSettings * sharedInstance = nil;

+(WorkoutMusicSettings *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

-(id) init {
    
    [self registerDefaultsFromSettingsBundle];
    return self;
}

- (void)registerDefaultsFromSettingsBundle {

    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary * defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    [preferences enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * prefSpec = (NSDictionary *) obj;
        NSLog(@"registering defaults: %@", [prefSpec objectForKey:@"Key"]);
        NSString *key = [prefSpec objectForKey:@"Key"];
        if (key) { 
            [defaultsToRegister setObject:[prefSpec objectForKey:@"DefaultValue"] forKey:key];
        }
        
    }];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

+(NSString *) workoutSongsPlaylist
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"workoutsongsplaylist"];
}
+(void) setWorkoutSongsPlaylist:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"workoutsongsplaylist"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"workoutsongschanged" object:self userInfo:nil];
}
@end
