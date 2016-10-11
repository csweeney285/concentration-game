//
//  ViewController.h
//  Concentration
//
//  Created by Conor Sweeney on 10/9/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardUIImageView.h"

@interface ViewController : UIViewController

@property (strong,nonatomic) UIView *containerView;
@property (strong,nonatomic) NSMutableArray *imageArray;

@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
- (IBAction)newGamePress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *gameButton;

@property int counter;
@property int cardMatchCounter;
@property BOOL flipBool;
@property int lastTag;
//@property (strong,nonatomic) CardUIImageView *lastImage;

-(void)downloadImagesFromFlickr;
-(void)cardFlipped;
-(void)addToCounter;
-(void)checkVictory;



@end

