//
//  NMGViewController.m
//  PhotoBrowser
//
//  Created by John on 13-3-18.
//  Copyright (c) 2013年 John. All rights reserved.
//haha

#import "NMGViewController.h"
#import "TFHpple.h"
#import "NNGImageViewController.h"
@interface NMGViewController ()
@end
@implementation NMGViewController
- (IBAction)pressOpenButton:(id)sender
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_URLUITextField.text]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if (response == nil){
        [_URLUITextField resignFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告！" message:@"无法连接到该网站！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
        [alertView release];
        return;
    }
    
     NSArray *imagesData =  [self parseData:response];
     NSMutableArray *images = [self downLoadPicture:imagesData];
    [self switchToImageView:images];
}


//解析html数据
- (NSArray*)parseData:(NSData*) data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    
    //在页面中查找img标签
    NSArray *images = [doc searchWithXPathQuery:@"//img"];
    [doc release];
    return images;
}


//下载图片的方法
- (NSMutableArray*)downLoadPicture:(NSArray *)images
{
    //创建存放UIImage的数组
     _downloadImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [images count]; i++){
        NSString *prefix = [[[images objectAtIndex:i] objectForKey:@"src"] substringToIndex:4];
        NSString *url = [[images objectAtIndex:i] objectForKey:@"src"];
        
        //判断图片的下载地址是相对路径还是绝对路径，如果是以http开头，则是绝对地址，否则是相对地址
        if ([prefix isEqualToString:@"http"] == NO){
            url = [_URLUITextField.text stringByAppendingPathComponent:url];
        }
        
        NSURL *downImageURL = [NSURL URLWithString:url];
        
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:downImageURL]];
        
        if(image != nil){
            [_downloadImages addObject:image];
            NSLog(@"66666666");
        }
        NSLog(@"下载图片的URL:%@", url);
    }
    return _downloadImages;
}


//显示图片的方法
- (void)switchToImageView:(NSMutableArray*)images
{
    //让_URLUITextField释放第一响应者，键盘关闭
    [_URLUITextField resignFirstResponder];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height)];
    
    scrollView.scrollEnabled = YES;
    
    _imageViewController =  [[NNGImageViewController alloc] initWithNibName:@"NNGImageViewController" bundle:nil];
    
    [_imageViewController.view addSubview:scrollView];
    
    int imageCount = [images count];
    
    //imageView宽度
    float width = 90.0f;
    
    //imageView高度
    float height = 80.0f;
    
    //列间距，即左右间隔
    float columnGap = (self.view.frame.size.width - width * 3) / 4;
    
    //行间距，即上下间隔
    float rowGap = 15.0f;
    
    int row;
    
    //計算有多少行圖片
    if (imageCount % 3 == 0) {
        row = imageCount / 3;
    } else {
         row = imageCount / 3 + 1;
    }
    
    int index = 0;
    
    for (int i = 0; i < row; i++) {
        
        for (int j = 0; j < 3; j++) {
            
            if (index >= imageCount) {
                break;
            }
            
            UIButton  *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(columnGap+(width+rowGap) * j, rowGap+(height+columnGap) * i, width, height)] ;
            
            [imageButton setImage:[[UIImageView alloc] initWithImage:[images objectAtIndex:index]].image forState:UIControlStateNormal];
            
            index++;
            
            //为按钮添加UITouch事件
            [imageButton addTarget:self action:@selector(clickPhoto:) forControlEvents:UIControlEventTouchUpInside];

            imageButton.backgroundColor = [UIColor brownColor];
            [scrollView addSubview:imageButton];
            [imageButton release];
            
        }
    }
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (height + rowGap) * row)];
    [self.view addSubview:_imageViewController.view];
    [scrollView release];
}


//当触摸图片时，响应该方法
- (void)clickPhoto:(UIButton *)button
{
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(290, 0, 15, 20)];
    
    //设置关闭按钮的图片
    [closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    
    closeButton.userInteractionEnabled = YES;
    
    //为关闭按钮添加UITouch事件
    [closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //从Button中取出图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[button currentImage]];
    
    //把图片放置在屏幕的中间
    [imageView setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [scrollView setContentSize:CGSizeMake(imageView.image.size.width,imageView.image.size.height)];
    [scrollView addSubview:imageView];
    scrollView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:200 alpha:0.7];
    [scrollView addSubview:closeButton];
    [self.view addSubview:scrollView];
    
    [closeButton release];
    [imageView release];
    [scrollView release];
}


//当点击关闭按钮时调用该方法
- (void)clickCloseButton:(UIButton *)button
{    
    [button.superview removeFromSuperview];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_URLUITextField release];
    [_connection release];
    [_openButton release];
    [_imageViewController release];
    [_downloadImages release];
    [super dealloc];
}

@end
