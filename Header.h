//
//  Header.h
//  InCloud
//
//  Created by Denis on 15/7/4.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#ifndef InCloud_Header_h
#define InCloud_Header_h
#define HScreen [[UIScreen mainScreen] bounds].size.height
#define WScreen [[UIScreen mainScreen] bounds].size.width
#define iOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define iOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0
#define StyleColor [UIColor colorWithRed:0.08 green:0.47 blue:0.84 alpha:1]



//判断iphone6
#define kiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iphone6+
#define kiPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
//判断ipad
#define kiPad ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#endif
