//
//  ViewController.m
//  Concentration
//
//  Created by Conor Sweeney on 10/9/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

//set api key
NSString * const FlickrAPIKey = @"5423dbab63f23a62ca4a986e7cbb35e2";

@implementation ViewController{
    CGFloat cardSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //set view to device size
    self.view.frame = [UIScreen mainScreen].bounds;

    //get card size
    //subtract 25 from the screen width since this allows for 5 space between the screen edges and each card
    cardSize = (self.view.frame.size.width - 25)/4;
    
    //center label and button
    self.gameButton.center = CGPointMake(50, 60);
    self.flipsLabel.center = CGPointMake(self.view.frame.size.width - 90, 60);
    
    
    //add container for the cards
    //make it a square and set to the screens width
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.width)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    
    //alloc memory
    self.imageArray = [NSMutableArray new];

    //add notification center to recieve notification when cards have been flipped
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cardFlipped:)
                                                 name:@"CardFlippedNotification"
                                               object:nil];
    
    [self downloadImagesFromFlickr];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadImagesFromFlickr{
    
    //set flip bool
    self.flipBool = NO;
    
    //set counters
    self.counter = 0;
    self.cardMatchCounter = 0;
    
    //set the tag to kitten
    NSString *tags = @"kitten";
    
    //set per page to 8

    NSString *urlString =[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=8&format=json&nojsoncallback=1",FlickrAPIKey, tags];
    
    //download json
    // Create NSURL string from formatted string
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest =[NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (error) {
                                              NSLog(@"error:%@\nlocalized:%@",error,error.localizedDescription);
                                          }
                                          else{
                                              // do something with the data
                                              //store the data into a dictionary
                                              NSError *jsonError;
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:&jsonError];
                                              //NSLog(@"%@",json);
                                              NSArray *photos = [[json objectForKey:@"photos"] objectForKey:@"photo"];
                                              for (NSDictionary *photo in photos){
                                                  
                                                  // Build the URL to where the image is stored (see the Flickr API)
                                                  // In the format http://farmX.static.flickr.com/server/id_secret.jpg
                                                  // Notice the "_s" which requests a "small" image 75 x 75 pixels
                                                  NSString *photoURLString =
                                                  [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
                                                   [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
                                                   [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
                                                  //NSLog(@"photoURLString: %@", photoURLString);
                                                  
                                                  //create uiimage
                                                  //add to image array
                                                  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
                                                  [self.imageArray addObject:image];

                                              }
                                              //create the cards using my custom class
                                              [self createCards];
                                          }
                                          
                                      }];
    [dataTask resume];
    [self addToCounter];
}

-(void)createCards{
    //create origin points first to help randomize order
    NSMutableArray *cardOriginArray = [NSMutableArray new];
    float xOrigin = 5;
    float yOrigin = 5;
    
    //run nested loop to get all points
    for (int i = 0; i<4; i++) {
        for (int j = 0; j<4; j++) {
            //add cpoint value to array to be used later
            [cardOriginArray addObject:[NSValue valueWithCGPoint:CGPointMake(xOrigin, yOrigin)]];
            //add to y origin
            yOrigin = yOrigin + 5 + cardSize;
        }
        //reset y origin
        yOrigin = 5;
        //add to x origin
        xOrigin = xOrigin + 5 + cardSize;
    }
    
    int tag = 1;
    for (UIImage*image in self.imageArray) {
        
        //get random point from array
        uint32_t rnd = arc4random_uniform((int)[cardOriginArray count]);
        NSValue *randomObject = [cardOriginArray objectAtIndex:rnd];
        CGPoint p = [randomObject CGPointValue];
        
        //use point to create card
        CardUIImageView *newCard = [[CardUIImageView alloc] initWithFrame:CGRectMake(p.x, p.y, cardSize, cardSize) andWithAnImage:image];
        
        //set tag
        newCard.tag = tag;
        [self.containerView addSubview:newCard];
        
        //remove that point from array
        [cardOriginArray removeObject:randomObject];
        
        //create a second instance of the same image with the same tag
        
        //get random point from array
        uint32_t rnd2 = arc4random_uniform((int)[cardOriginArray count]);
        NSValue *randomObject2 = [cardOriginArray objectAtIndex:rnd2];
        CGPoint p2 = [randomObject2 CGPointValue];
        
        //use point to create card
        CardUIImageView *newCard2 = [[CardUIImageView alloc] initWithFrame:CGRectMake(p2.x, p2.y, cardSize, cardSize) andWithAnImage:image];
        
        //set tag
        newCard2.tag = tag;
        [self.containerView addSubview:newCard2];
        
        //remove that point from array
        [cardOriginArray removeObject:randomObject2];

        tag++;
    }
}

-(void)cardFlipped: (NSNotification *) notification{
    NSLog(@"Card Flipped");
    if (self.flipBool == YES) {
        if ([notification.object tag]==self.lastTag) {
            NSLog(@"Match");
            self.cardMatchCounter++;
            for (UIView *i in self.containerView.subviews){
                if([i isKindOfClass:[CardUIImageView class]]){
                    CardUIImageView *newLbl = (CardUIImageView *)i;
                    if(newLbl.tag == self.lastTag){
                        //found a match
                        //disable user interaction
                        newLbl.userInteractionEnabled = NO;
                    }
                }
            }
        }
        else{
            NSLog(@"No Match");
            //find the incorrect views
            for (UIView *i in self.containerView.subviews){
                if([i isKindOfClass:[CardUIImageView class]]){
                    CardUIImageView *newLbl = (CardUIImageView *)i;
                    if(newLbl.tag == self.lastTag || newLbl.tag == [notification.object tag]){
                        //flip them back
                        [newLbl wrongMatch];
                    }
                }
            }
            //[notification.object wrongImage];
            //[self.lastImage wrongImage];
            //self.lastImage = nil;
            
        }
        self.flipBool = NO;
    }
    else{
        self.lastTag = (int)[notification.object tag];
        self.flipBool = YES;
    }
    self.counter++;
    [self addToCounter];
    
}
-(void)addToCounter{
    self.flipsLabel.text = [NSString stringWithFormat:@"Number of Flips: %d",self.counter];
    //check matches
    [self checkVictory];
}
-(void)checkVictory{
    if (self.cardMatchCounter == 8) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"YOU WON"
                                      message:@"You matched all the kittens! Would you like to play again?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"YES"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self newGamePress:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"NO"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (IBAction)newGamePress:(id)sender {
    //remove all cards and all images
    //redownload new images from flickr
    //it could simply reuse the images already downloaded but I made an executive decision to download new images in case new images have been uploaded
    [self.containerView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.imageArray removeAllObjects];
    [self downloadImagesFromFlickr];
}
@end
