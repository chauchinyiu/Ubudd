//
//  WUHairLine.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 4/8/2015.
//  Copyright (c) 2015年 3Embed Technologies. All rights reserved.
//

#import "WUHairLine.h"

@implementation WUHairLine

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}
*/

-(void)awakeFromNib {
    /*
    self.layer.borderColor = [self.backgroundColor CGColor];
    self.layer.borderWidth = (1.0 / [UIScreen mainScreen].scale) / 2;
    
    self.backgroundColor = [UIColor clearColor];
    */
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-0.5f, self.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [self.backgroundColor CGColor];
    [self.layer addSublayer:bottomBorder];
    self.backgroundColor = [UIColor clearColor];
}

@end
