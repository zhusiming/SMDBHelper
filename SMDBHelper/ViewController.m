//
//  ViewController.m
//  SMDBHelper
//
//  Created by 朱思明 on 16/7/1.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import "ViewController.h"
#import "SMDBHelper.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.创建一个表
    NSString *sql1 = @"create table Image(ImageName text,ImageData blob)";
    BOOL isOk = [SMDBHelper createTableWithSqlString:sql1];
    NSLog(@"创建：%@",isOk == YES ? @"成功" : @"失败");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)writeData:(id)sender {
    // 把图片写入数据库
    
    // 创建sql语句
    NSString *sql = @"insert into Image(ImageName,ImageData) values(?,?)";
    // 03.绑定参数
    NSString *imageName = @"1.png";
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"1.png"]);
    
    BOOL isOk = [SMDBHelper execTableWithSqlString:sql paramsArgs:imageName,imageData, nil];
    
    NSLog(@"保存：%@",isOk == YES ? @"成功" : @"失败");
    
}

- (IBAction)readData:(id)sender {
    
    [SMDBHelper selectTableWithSqlString:@"select * from Image" params:nil selectFinishBlock:^(NSArray *dataList, NSString *error) {
        if (error == nil) {
            NSLog(@"dataList:%@",dataList);
            // 获取当前内容的字典
            NSDictionary *dic = [dataList lastObject];
            _titleLabel.text = dic[@"ImageName"];
            _imageView.image = [UIImage imageWithData:dic[@"ImageData"]];
        }
    }];
}

















@end
