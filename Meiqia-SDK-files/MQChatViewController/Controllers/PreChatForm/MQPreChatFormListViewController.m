//
//  MQPreAdviseFormListViewController.m
//  Meiqia-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Meiqia. All rights reserved.
//

#import "MQPreChatFormListViewController.h"

@interface MQPreChatFormListViewController ()

@property (nonatomic, weak) MQChatViewConfig *config;

@end

@implementation MQPreChatFormListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MQPreChatFormListViewController *)appendPreChatWithConfig:(MQChatViewConfig *)config on:(UIView*)view completion:(CompleteBlock)block {
    self.CompleteBlock = block;
    self.config = config;
    
    [view addSubview:self.view];
    return self;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
