//
//  CardUIImageView.m
//  Concentration
//
//  Created by Conor Sweeney on 10/9/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import "CardUIImageView.h"

@implementation CardUIImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//custom init
- (id)initWithFrame:(CGRect)aRect andWithAnImage: (UIImage*)imageForCard
{
    self = [super initWithFrame:aRect];
    //customize aesthetics
    self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 3.0;
    self.layer.cornerRadius = 8;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    
    //customize settings
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    //turn on user interaction
    self.userInteractionEnabled = YES;
    
    //set placeholder image and bool
    self.placeholderBool = YES;
    self.placeholderImage = [UIImage imageNamed:@"questionmark.png"];
    self.image = self.placeholderImage;
    
    //set card image
    self.cardImage = imageForCard;
    
    //add wrong image over
    self.wrongImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
    self.wrongImage.contentMode = UIViewContentModeScaleAspectFit;
    self.wrongImage.image = [UIImage imageNamed:@"wrong.png"];
    self.wrongImage.alpha = 0;
    [self addSubview:self.wrongImage];
    
    //add gesture recognizer
    //interaction will be disabled from the view controller when cards are matched
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(cardFlip)];
    [self addGestureRecognizer:singleFingerTap];
    
    return self;
}

- (void)cardFlip {
    //flip animation for when card is selected
    [UIView transitionWithView:self
                      duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations: ^{
                        if (self.placeholderBool == YES) {
                            self.image = self.cardImage;
                            self.placeholderBool = NO;
                            //send notification to add to counter
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"CardFlippedNotification"
                             object:self];
                        }
                        else{
                            self.image = self.placeholderImage;
                            self.placeholderBool = YES;
                        }
                    }
                    completion:NULL];
}

//animation to add an x over a wrong match and flip the cards back
-(void)wrongMatch{
    
    //only flip it if it is not showing the place holder
    if (self.placeholderBool == NO) {
        [UIView animateWithDuration:1.8
                         animations:^{self.wrongImage.alpha = 1;}
                         completion:^(BOOL finished){
                             self.wrongImage.alpha = 0;
                             [self cardFlip];
                         }];
    }
}


@end
