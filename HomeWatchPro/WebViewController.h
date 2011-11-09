//
//  WebViewController.h
//  HomeWatchPro
//
//  Created by Stitz on 6/23/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
    NSString            *urlString;
    NSString            *postId;
    NSMutableString     *author;
    NSURLRequest        *linkRequest;
    UIWebView           *webview;
}

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSURLRequest *linkRequest;
@property (nonatomic, retain) IBOutlet UIWebView *webview;

- (IBAction)done;
- (void)loadUrl;
- (void)setupWebView;

@end
