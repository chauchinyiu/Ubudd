//
//  WUTabBar.m
//  UpBrink
//
//  Created by Ming Kei Wong on 25/4/2015.
//  Copyright (c) 2015年 3Embed Technologies. All rights reserved.
//

#import "WUTabBar.h"

@implementation WUTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 39;
    
    return sizeThatFits;
}

@end
