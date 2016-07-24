//
//  SecneTableViewCell.h
//  InCloud
//
//  Created by Denis on 15/7/29.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLRadioButton/DLRadioButton.h"
#import "GCDAsyncUdpSocket.h"
#import "AtuInfo.h"
#import "DaiKinStatus.h"


@interface SecneTableViewCell : UITableViewCell<GCDAsyncUdpSocketDelegate>{
    IBOutlet DLRadioButton *onbtn;
    IBOutlet DLRadioButton *offbtn;
    
    IBOutlet DLRadioButton *coldbtn;
    IBOutlet DLRadioButton *heatbtn;
    IBOutlet DLRadioButton *fanbtn;
    IBOutlet DLRadioButton *dehubtn;
    
    IBOutlet DLRadioButton *lowbtn;
    IBOutlet DLRadioButton *centerbtn;
    IBOutlet DLRadioButton *strongbtn;
    
    IBOutlet DLRadioButton *fixbtn;
    IBOutlet DLRadioButton *scanbtn;
    
    IBOutlet UISlider *tempslider;
    IBOutlet UILabel  *templbl;
    
    IBOutlet UIButton *savebtn;
    IBOutlet UIButton *calbtn;
    NSInteger Reqflag;
    DaiKinStatus *dkStatus;
    DaiKinStatus *setStatus;
    AtuInfo *dev;
    GCDAsyncUdpSocket *sendUdpSocket;
}
@property(nonatomic, strong)IBOutlet DLRadioButton *onbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *offbtn;

@property(nonatomic, strong)IBOutlet DLRadioButton *coldbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *heatbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *fanbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *dehubtn;

@property(nonatomic, strong)IBOutlet DLRadioButton *lowbtn;
;
@property(nonatomic, strong)IBOutlet DLRadioButton *centerbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *strongbtn;

@property(nonatomic, strong)IBOutlet DLRadioButton *fixbtn;
@property(nonatomic, strong)IBOutlet DLRadioButton *scanbtn;

@property(nonatomic, strong)IBOutlet UISlider *tempslider;
@property(nonatomic, strong)IBOutlet UILabel  *templbl;

@property(nonatomic, strong)IBOutlet UIButton *savebtn;
@property(nonatomic, strong)IBOutlet UIButton *calbtn;
-(void)initCell:(AtuInfo *)atu;
- (IBAction)savePressed : (id)sender;
- (IBAction)calPressed : (id)sender;
@end
