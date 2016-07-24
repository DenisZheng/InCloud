//
//  ViewController.h
//  InCloud
//
//  Created by Denis on 15/7/3.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"
//#import "GCDAsyncUdpSocket.h"
@interface ViewController : UIViewController<SlideNavigationControllerDelegate>{
    NSMutableArray *atus;

    NSTimer *mytimer;
    IBOutlet UITableView* mytable;
    
}
@property(nonatomic, strong)IBOutlet UITableView* mytable;
@property(nonatomic,retain)NSMutableArray *atus;
@property(nonatomic,retain)NSTimer *mytimer;
@end

