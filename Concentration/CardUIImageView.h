//
//  CardUIImageView.h
//  Concentration
//
//  Created by Conor Sweeney on 10/9/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//custom UIImageView class

@interface CardUIImageView : UIImageView

@property (strong,nonatomic) UIImage *placeholderImage;
@property (strong,nonatomic) UIImage *cardImage;
@property (strong,nonatomic) UIImageView *wrongImage;


//set a bool value to tell whether the image is the placeholder or the real image
@property BOOL placeholderBool;

//custom init
- (id)initWithFrame:(CGRect)aRect andWithAnImage: (UIImage*)imageForCard;

- (void)cardFlip;
-(void)wrongMatch;



@end
