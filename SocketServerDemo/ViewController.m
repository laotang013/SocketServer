//
//  ViewController.m
//  SocketServerDemo
//
//  Created by Start on 2017/7/17.
//  Copyright © 2017年 het. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *PortText;
@property (weak, nonatomic) IBOutlet UIButton *ListenBtn;
@property (weak, nonatomic) IBOutlet UITextField *SendDataText;
@property (weak, nonatomic) IBOutlet UIButton *SendBtn;
@property (weak, nonatomic) IBOutlet UITextView *TextViewStr;

/**服务器Socket*/
@property(nonatomic,strong)GCDAsyncSocket *socktServer;
/**保存的客户端Socket*/
@property(nonatomic,strong)GCDAsyncSocket *socketClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     首先调用Socket函数创建一个Socket函数创建一个Socket，然后调用bind函数将其与本机地址以及一个本地端口号绑定。然后调用listen在相应的socket上监听，当accept接收到一个连接服务请求时，将生成一个新的Socket，服务器显示该客户机的IP地址，并将通过socket向客户端发送数据，最后关闭该Socket。
     */
    //1 初始化socket
    self.socktServer = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

//2.监听端口号
- (IBAction)listenBtn:(id)sender {
    NSError *error = nil;
    uint16_t port = self.PortText.text.integerValue;
    BOOL result = [self.socktServer acceptOnPort:port error:&error];
    if (result && error == nil) {
        [self showMessageStr:[NSString stringWithFormat:@"监听端口%hu",port]];
    }
}

//发送消息
- (IBAction)sendDataBtn:(id)sender {
    NSData *data = [self.SendDataText.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.socketClient writeData:data withTimeout:-1 tag:0];
}


-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"服务器写入成功");
}

//回收键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - **************** GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //保存客户端的socket
    self.socketClient = newSocket;
    [self showMessageStr:@"连接成功"];
    [self showMessageStr:[NSString stringWithFormat:@"客户端地址%@ - 端口%d",newSocket.connectedHost,newSocket.connectedPort]];
    [self.socketClient readDataWithTimeout:-1 tag:0];
}

//接收到客户端发送来的消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageStr:text];
    [self.socketClient readDataWithTimeout:-1 tag:0];
}



-(void)showMessageStr:(NSString *)str
{
    self.TextViewStr.text = [self.TextViewStr.text stringByAppendingFormat:@"%@\n",str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
