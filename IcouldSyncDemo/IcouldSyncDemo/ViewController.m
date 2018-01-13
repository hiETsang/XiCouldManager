//
//  ViewController.m
//  IcouldSyncDemo
//
//  Created by canoe on 2018/1/11.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "ViewController.h"
#import "XiCouldManager.h"
#import "XPlistFileManager.h"
#import "XDocument.h"

@interface ViewController ()

@property (strong, nonatomic) NSMetadataQuery *query;/* 查询文档对象 */

@property(nonatomic, copy)NSString *fileName;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextField *textFiled;

@end

@implementation ViewController

- (IBAction)buttonClick:(id)sender {
    [[XiCouldManager sharedManager] downloadFromiCloud:@"1.txt" localfile:@"2.txt" callBack:^(BOOL success,id obj) {
        if (success) {
            NSLog(@"文件下载完成，路径 ---------> %@\n可以打开沙盒查看",[XPlistFileManager getPlistPathWithName:@"2.txt"]);
        }
    }];
}

- (IBAction)updateButton:(id)sender {
    if (self.textFiled.text.length <= 0) {
        NSLog(@"请输入文字再上传");
        return;
    }
    //本地创建好一个txt文件
    [XPlistFileManager createPlistInSandBoxDoucumentWithContent:self.textFiled.text name:@"1.txt"];
    //判断icloud是否可用
    if ([[XiCouldManager sharedManager] iCloudEnable]) {
        //上传icloud文件
        [[XiCouldManager sharedManager] uploadToiCloud:@"1.txt" localFile:@"1.txt" callBack:^(BOOL success) {
            NSLog(@"---------> %@",success == YES?@"上传成功":@"上传失败");
        }];
    }
}


- (IBAction)deleteiCloudFile:(id)sender {
    [[XiCouldManager sharedManager] removeFileIniCloud:@"1.txt"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //验证iCloud是否同步成功步骤：
//    1.点击上传，将输入框中的文字保存到1.txt中，上传到icloud
//    2.上传成功调用刷新方法，在回调中会打印icloud中的所有文件
//    3.点击下载，将icloud中的1.txt保存到本地沙盒的2.txt文件中
//    4.沙盒路径打印出来，可以直接跳转沙盒查看。
    
    //注意：使用iCloud同步的前提是配置好证书和打开capabilities中的iCloud Documents
    //     验证到第二步其实已经可以看到文件是否上传成功，建议使用真机调试
    
    
    //icloud刷新后会回调这个方法
    [[XiCouldManager sharedManager] setMetadataQueryDidUpdate:^(NSArray<NSMetadataItem *> *array) {
        NSString *str = @"文件列表：";
        for (NSMetadataItem *item in array) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"\n%@",[item valueForAttribute:NSMetadataItemFSNameKey]]];
            
        }
        NSLog(@"%@", str);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
