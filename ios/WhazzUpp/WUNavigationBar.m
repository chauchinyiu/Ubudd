//
//  WUNavigationBar.m
//  WhazzUpp
//
//  Created by Ming Kei Wong on 23/6/2015.
//  Copyright (c) 2015年 3Embed Technologies. All rights reserved.
//

#import "WUNavigationBar.h"

@implementation WUNavigationBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)layoutSubviews{
    self.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 0);
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize s = [super sizeThatFits:size];
    s.height = 32; // Or some other height
    return s;
}


@end
