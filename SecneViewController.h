//
//  SecneViewController.h
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "GCDAsyncUdpSocket.h"
@interface SecneViewController : UIViewController<SlideNavigationControllerDelegate,GCDAsyncUdpSocketDelegate>{
     NSMutableArray *atus;
    
     IBOutlet UITableView* mytable;
     GCDAsyncUdpSocket *sendUdpSocket;
}
@property(nonatomic,retain)NSMutableArray *atus;
@property(nonatomic, strong)IBOutlet UITableView* mytable;

@end
