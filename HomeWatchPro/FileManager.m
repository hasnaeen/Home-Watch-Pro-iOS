//
//  FileManager.m
//  HomeWatchPro
//
//  Created by USER on 7/20/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "FileManager.h"
#import "AlertManager.h"

@implementation FileManager

- (void)saveImage:(UIImage*)image:(NSString*)imageName {
    
    NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    NSLog(@"image saved");
    
}

//removing an image

- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    
    [fileManager removeItemAtPath: fullPath error:NULL];
    
    NSLog(@"image removed");
    
}

- (void)RemoveAllFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *all = [fileManager directoryContentsAtPath: documentsDirectory];
    
    for (int i=0;i<[all count];i++) {
        NSString *fileName = [[NSString alloc] initWithFormat:@"%@",[all objectAtIndex:i]];
        
        if([fileName length]>=5)
        {
            NSString *startName = [fileName substringWithRange:NSMakeRange(0, 5)];
        
            if([startName isEqualToString:@"Local"]==TRUE)
            {
                [self removeImage:fileName];
            }
        }
    }
}


//loading an image

- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}

@end
