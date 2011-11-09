//
//  FileManager.h
//  HomeWatchPro
//
//  Created by USER on 7/20/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManager : NSObject {
    
}

- (void)saveImage:(UIImage*)image:(NSString*)imageName;
- (void)removeImage:(NSString*)fileName;
- (UIImage*)loadImage:(NSString*)imageName;
- (void)RemoveAllFile;

@end
