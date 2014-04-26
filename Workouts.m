//
//  Workouts.m
//  WorkoutInterval
//
//  Created by La Barge, John on 10/27/13.
//
//

#import "Workouts.h"
#import "Workout.h"

@implementation Workouts
+(NSString *) path
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    NSURL * docsDir = [[fileMgr URLsForDirectory:NSDocumentDirectory
                        
                                       inDomains:NSUserDomainMask] lastObject];
    NSString * workoutsPath = [docsDir.path stringByAppendingPathComponent:@"workouts"];
    
    NSError *error;
    BOOL isDir = YES;
    if (![fileMgr fileExistsAtPath:workoutsPath isDirectory:&isDir]) {
        if (![fileMgr createDirectoryAtPath:workoutsPath withIntermediateDirectories:NO attributes:nil error:&error])
            NSLog(@"%@",[error localizedDescription]);
        
    }
    return workoutsPath;

}
+(NSArray *) list {
    NSLog(@"list.....");
    NSString * dirPath = [self path];
    NSMutableArray * theArray = [[NSMutableArray alloc] initWithCapacity:20];
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    NSError * error;
    NSArray *filelist = [fileMgr contentsOfDirectoryAtPath:dirPath error:&error];
    
    [filelist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * filename = (NSString *) obj;
        NSString *fullPath = [dirPath stringByAppendingPathComponent:filename];
        BOOL isDir;
        [fileMgr fileExistsAtPath:fullPath isDirectory:&isDir];
        if (!isDir) {
            NSError *error;
           // NSLog(@"loading workout at %@",fullPath);
            NSData * data = [NSData dataWithContentsOfFile:fullPath];
            NSDictionary * workoutDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                             error:&error];
            if (!workoutDict) {
                NSLog(@"%@", [error localizedDescription]);
            } else {
                Workout * workout = [[Workout alloc] initFromDict: workoutDict];
                [theArray addObject:workout];
            }
            
        } else {
            NSLog(@"%@ is a directory.",fullPath);
        
        }
    }];
     NSLog(@"Returning array of size:%d",theArray.count);
    return theArray;
        
    
    
}

@end
