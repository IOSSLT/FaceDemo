//
//  ImageViewController.m
//  TextDemo
//
//  Created by 喵了个咪 on 16/5/16.
//  Copyright © 2016年 mm. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatHeadImg];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"图像结果";
}

- (void)creatHeadImg{
    NSLog(@"%f %f",_headImg.size.width,_headImg.size.height);
    CGFloat faceH = 200;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - faceH) / 2, (480 - faceH) / 2, faceH, faceH)];
    imgView.image = _headImg;
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    [self.view addSubview:imgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
