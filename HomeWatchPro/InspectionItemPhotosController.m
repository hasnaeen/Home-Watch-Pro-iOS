//
//  InspectionItemPhotosController.m
//  HomeWatchPro
//
//  Created by USER on 7/10/11.
//  Copyright 2011 CSN Media. All rights reserved.
//

#import "InspectionItemPhotosController.h"
#import "CoreDataManager.h"
#import "AlertManager.h"
#import "MediaObject.h"
#import "MBProgressHUD.h"
#import "InspectionItem.h"
#import "InspectionItemDetailsViewController.h"
#import "SDWebImageManager.h"

@implementation InspectionItemPhotosController

@synthesize fileManager;
@synthesize currentInspectionItemID,inspectionItemPhotosArray,currentInspectionID,currentInspection,tempAddInspectionItemPhotosArray;
@synthesize managedObjectContext=__managedObjectContext;

NSInteger numberOfImages,currentImageIndex;


-(void)Context:(NSManagedObjectContext *) context
{
    self.managedObjectContext = context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fileManager = [FileManager alloc];
    currentImageIndex = 0;
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    
    NSMutableArray *dataInspection = [dataManager GetInspectionByID:currentInspectionID];
    
    if([dataInspection count]>0)
        currentInspection = (Inspections*) [dataInspection objectAtIndex:0];
    else
        currentInspection = NULL;
    
    NSMutableArray *data = [dataManager GetInspectionItemByID:currentInspectionItemID InspectionID:currentInspectionID];
    
    if([data count]>0)
    {
       InspectionItem *currentInspectionItem = (InspectionItem*) [data objectAtIndex:0];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateNormal];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateHighlighted];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateDisabled];
        [btnBack setTitle:[NSString stringWithFormat:@" %@",[currentInspectionItem Name]] forState:UIControlStateSelected];
        
        NSString *temp = [NSString stringWithFormat:@" %@",[currentInspectionItem Name]];
        
        if([temp length]>8)
        {
            btnBack.frame = CGRectMake(17, 8, ([temp length] - 8) * 6 + 75, 30);
        }
    }
    
    numberOfImages = [inspectionItemPhotosArray count];
    [self ImageLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [inspectionItemPhotosArray release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)ImageLoad
{
    #ifdef __BLOCKS__
    NSLog(@"%@",currentInspection.IsQueued);
    NSLog(@"%@",currentInspection.Status);
    NSLog(@"%d",numberOfImages);
    
    if([currentInspection.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE || numberOfImages >= 3)
        btnAddPhoto.hidden = TRUE;
    else
        btnAddPhoto.hidden = FALSE;
    
    if(currentImageIndex == 0)
        btnPrevious.hidden = TRUE;
    else
        btnPrevious.hidden = FALSE;
    
    if(currentImageIndex == (numberOfImages - 1)||
       numberOfImages == 0)
        btnNext.hidden = TRUE;
    else
        btnNext.hidden = FALSE;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Data";
    
    if(currentImageIndex < numberOfImages)
    {
        imageLabel.text =[NSString stringWithFormat:@"%d of %d",(currentImageIndex + 1),numberOfImages];
        topBarImage.image = [UIImage imageNamed:@"transparent_bar.png"];
        buttomBarImage.hidden = FALSE;
        btnBackEmpty.hidden = TRUE;
        btnBack.hidden = FALSE;
        noImageLabel1.hidden = TRUE;
        noImageLabel2.hidden = TRUE;
    }
    else
    {
        imageLabel.text = @"";
        //currentImage.backgroundColor = [UIColor blackColor];
        [currentImage setImage:NULL];
        btnDeletePhoto.hidden = TRUE;
        topBarImage.image = [UIImage imageNamed:@"bannerTop.png"];
        buttomBarImage.hidden = TRUE;
        btnBack.hidden = TRUE;
        btnBackEmpty.hidden = FALSE;
        noImageLabel1.hidden = FALSE;
        noImageLabel2.hidden = FALSE;
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        BOOL hasRemoveLoading = YES;
        
        if(currentImageIndex < numberOfImages)
                {
                    NSString *url = [[NSString alloc] init];
                    
                    if(currentImageIndex < numberOfImages)
                    {
                        NSLog(@"%d",currentImageIndex);
                        MediaObject *item = [MediaObject alloc];
                        item = (MediaObject *)[inspectionItemPhotosArray objectAtIndex:currentImageIndex];
                        url =[item URL];
                        
                        if([currentInspection.IsQueued isEqualToNumber: [NSNumber numberWithBool:YES]]==TRUE || [currentInspection.Status isEqualToString:@"Received"]==TRUE )
                            [self performSelectorOnMainThread:@selector(DeleteButtonHidden) withObject:NULL waitUntilDone:YES];             
                        else
                            [self performSelectorOnMainThread:@selector(DeleteButtonVisible) withObject:NULL waitUntilDone:YES];                                                        
                    }
                    else
                    {
                        url = (NSString *)[tempAddInspectionItemPhotosArray objectAtIndex:(currentImageIndex - [inspectionItemPhotosArray count])];
                    }
                    
                    UIImage * image = [UIImage alloc];
                    NSString *startUrl = [url substringWithRange:NSMakeRange(0, 5)];
                    
                    if([startUrl isEqualToString:@"Local"]==TRUE)
                    {
                        hasRemoveLoading = YES;
                        image = [fileManager loadImage:url];
                        [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:image waitUntilDone:YES];
                    }
                    else if(currentImageIndex < numberOfImages)
                    {
                        hasRemoveLoading = NO;
                        NSString * encodedString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
                        NSURL * imageURL = [NSURL URLWithString:encodedString];
                        image = [self ImageDownloadFromWeb:imageURL];
                        
                        if(image != NULL)
                        {
                            hasRemoveLoading = YES;
                            CoreDataManager *dataManager = [CoreDataManager alloc];
                            [dataManager Context:__managedObjectContext]; 
                            MediaObject *item = [MediaObject alloc];
                            item = (MediaObject *)[inspectionItemPhotosArray objectAtIndex:currentImageIndex];
                            NSDate *now = [NSDate date];
                            NSString *imageName = [[NSString alloc] initWithFormat:@"Local-%@-%@-%@-%d",currentInspectionID,currentInspectionItemID,now,currentImageIndex]; 
                            [fileManager saveImage:image :imageName];
                            [item setURL:imageName];
                            [dataManager SaveObjectContext];
                            [dataManager release];
                            [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:image waitUntilDone:YES];
                        }
                        //NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                        //image = [UIImage imageWithData:imageData];
                    }
                }
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(hasRemoveLoading == YES)
                    {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        app.networkActivityIndicatorVisible = NO;
                    }
                });
            }); 
    #endif
}

- (void)DeleteButtonHidden
{
    btnDeletePhoto.hidden = TRUE;
}

- (void)DeleteButtonVisible
{
    btnDeletePhoto.hidden = FALSE;
}

- (UIImage *) ImageDownloadFromWeb:(NSURL *)url
{
    SDWebImageManager *webImageManager = [SDWebImageManager sharedManager];
    UIImage *loadedImage = [webImageManager imageWithURL:url];
    
    if (loadedImage)
    {
        // Use the cached image immediatly
    }
    else
    {
        // Start an async download
        [webImageManager downloadWithURL:url delegate:self];
    }    
    
    return loadedImage;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    CoreDataManager *dataManager = [CoreDataManager alloc];
    [dataManager Context:__managedObjectContext]; 
    MediaObject *item = [MediaObject alloc];
    item = (MediaObject *)[inspectionItemPhotosArray objectAtIndex:currentImageIndex];
    NSDate *now = [NSDate date];
    NSString *imageName = [[NSString alloc] initWithFormat:@"Local-%@-%@-%@-%d",currentInspectionID,currentInspectionItemID,now,currentImageIndex]; 
    [fileManager saveImage:image :imageName];
    [item setURL:imageName];
    [dataManager SaveObjectContext];
    [dataManager release];   
    [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:image waitUntilDone:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;   
}

-(void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:NULL waitUntilDone:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    AlertManager *alert = [AlertManager alloc];
    [alert showAlert:[NSString stringWithFormat:@"%@",error] Title:@"Image Loading Error"];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(didLoadImageInBackground:) withObject:NULL waitUntilDone:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    AlertManager *alert = [AlertManager alloc];
    [alert showAlert:[NSString stringWithFormat:@"%@",error] Title:@"Image Loading Error"];
}

- (void)didLoadImageInBackground:(UIImage *)image {
    
    [currentImage setImage: image];
    
    CGFloat totalWidth = self.view.frame.size.width;
    CGFloat totalHeight = self.view.frame.size.height;
    
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if(width>totalWidth)
    {
        height = (height * totalWidth) / width;
        width = totalWidth;
    }
    
    if(height > totalHeight)
    {
        width = (width * totalHeight) / height;
        height = totalHeight;
    }
    
    [currentImage setFrame:CGRectMake(0, 0, width, height)];
    currentImage.center = CGPointMake(totalWidth/2, self.view.center.y);
}

- (IBAction)BackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)DeleteClick:(id)sender
{
    MediaObject *item = [MediaObject alloc];
    item = (MediaObject *)[inspectionItemPhotosArray objectAtIndex:currentImageIndex];   
    
    if(item.IsSubmitted != NULL && [item.IsSubmitted isEqualToNumber:[NSNumber numberWithBool:YES]]==TRUE)    
        [item setIsDeleted:[NSNumber numberWithBool:YES]];
    else
        [__managedObjectContext deleteObject:item];
    
    InspectionItemDetailsViewController *parent = (InspectionItemDetailsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    [parent EditSave:@"Save"];
    inspectionItemPhotosArray = [parent currentInspectionItemImages];
    tempAddInspectionItemPhotosArray = [parent tempAddInspectionItemPhotosArray];
    //currentInspection = [parent currentInspection];
    
    NSInteger tempIndex = currentImageIndex;
    if(tempIndex > 0)
        tempIndex--;
    currentImageIndex = tempIndex;
    numberOfImages--;
    [self ImageLoad];    
}

- (IBAction)ImageChangeClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if(numberOfImages >0)
    {
        NSInteger tempIndex = currentImageIndex;
        
        if(button == btnNext)
        {
            tempIndex = (tempIndex + 1)%numberOfImages;
            currentImageIndex = tempIndex;
        }
        else if(button == btnPrevious)
        {
            tempIndex = tempIndex - 1;
        
            if(tempIndex<0)
                tempIndex = numberOfImages - 1;
            currentImageIndex = tempIndex;
        }
    }
    
    [self ImageLoad];
}

bool availableCamera = YES;
- (IBAction)AddImageClicked:(id)sender
{
    UIActionSheet *actionSheet = NULL; 
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New Photo",@"Choose Existing Photo",nil];
    else
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing Photo",nil];
	
    [actionSheet showInView:self.view];
	[actionSheet release];
    
    /*
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentModalViewController:controller animated:YES];
    [controller release];
    */
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if(buttonIndex == 0)
    {
        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
    
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            //controller.mediaTypes = [NSArray arrayWithObjects:(NSString *) KUTTypeImage, nil];
            controller.allowsEditing = NO;
        }
        else
            controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
	else if(buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
}


-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    NSLog(@"%@",currentInspection.IsQueued);
    UIImage* image = [UIImage alloc];
    image = [self scaleAndRotateImage: [info objectForKey: UIImagePickerControllerOriginalImage]];
    currentImage.image = image;
    NSDate *now = [NSDate date];
    NSString *imageName = [[NSString alloc] initWithFormat:@"Local-%@-%@-%@",currentInspectionID,currentInspectionItemID,now]; 
    [fileManager saveImage:image :imageName];
    [picker dismissModalViewControllerAnimated:YES];
    [tempAddInspectionItemPhotosArray addObject:imageName];
    numberOfImages++;
    currentImageIndex = (numberOfImages - 1);
    NSLog(@"%@",currentInspection.IsQueued);
    InspectionItemDetailsViewController *parent = (InspectionItemDetailsViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    [parent EditSave:@"Save"];
    inspectionItemPhotosArray = [parent currentInspectionItemImages];
    tempAddInspectionItemPhotosArray = [parent tempAddInspectionItemPhotosArray];
    [self ImageLoad];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return imageCopy;
}

@end
