//
//  DYNavigationController.m
//  Pop
//
//  Created by Mr.Yang on 2016/11/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "DYNavigationController.h"

@interface DYNavigationController ()
typedef enum {
    Nothing = 0,
    Vague = 1,
    Horizontal = 2,
    Vertical
}DIRECTION;
@end

@interface DYNavigationController ()
{
    UIImageView *belowImageView;
    UIView *grayView;
    DIRECTION direction;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *backgroundImageList;

@end

@implementation DYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
    [self addGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.backgroundView = nil;
}

- (void)addGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [pan delaysTouchesBegan];
    [self.view addGestureRecognizer:pan];
}


- (void)panAction:(UIPanGestureRecognizer *)pan
{
    if (self.viewControllers.count <= 1) {
        return;
    }
    
    CGPoint point = [pan translationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            self.backgroundView.backgroundColor = [UIColor blackColor];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            grayView.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:grayView];
            
        }
        self.backgroundView.hidden = false;
        
        if (belowImageView) {
            [belowImageView removeFromSuperview];
        }
        belowImageView = [[UIImageView alloc] initWithImage:[self.backgroundImageList lastObject]];
        [self.backgroundView insertSubview:belowImageView atIndex:0];
        
        direction = Nothing;
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGFloat x = direction == Horizontal ? point.x : direction == Vertical ? point.y : 0;
        
        
        if (x > 50) {
            [UIView animateWithDuration:0.25 animations:^{
                CGFloat k;
                direction == Horizontal ? k = self.view.frame.size.width : direction == Vertical ? k = self.view.frame.size.height : 0;
                [self belowImageViewScale:k];
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:false];
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }];
            
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                [self belowImageViewScale:0];
            } completion:^(BOOL finished) {
                self.backgroundView.hidden = true;
            }];
        }
        
        direction = Nothing;
         
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        if (!direction) {
            if (point.x > point.y && point.x > 0) {
                direction = Horizontal;
            } else if (point.y > point.x && point.y > 0) {
                direction = Vertical;
            } else {
                direction = Vague;
            }
        }
        if (direction && direction != Vague) {
            CGFloat x;
            direction == Horizontal ? x = point.x : direction == Vertical ? x = point.y : 0;
            [self belowImageViewScale:x];
        }
    }
    
}

#pragma mark - belowImageView 的缩放 和 self.view 移动
- (void)belowImageViewScale:(CGFloat)x
{
    x = x < 0 ? 0 : x;
    
    CGFloat scale;
    CGFloat alpha;
    CGRect frame = self.view.frame;
    if (direction == Horizontal) {
        frame.origin.x = x;
        scale = 0.95 + x / self.view.frame.size.width / 20.0f;
        alpha = 0.5 - x / self.view.frame.size.width / 2.0f;
    } else if (direction == Vertical) {
        frame.origin.y = x;
        scale = 0.95 + x / self.view.frame.size.height / 20.0f;
        alpha = 0.5 - x / self.view.frame.size.height / 2.0f;
    }
    self.view.frame = frame;
    grayView.alpha = alpha;
    
    belowImageView.transform = CGAffineTransformMakeScale(scale, scale);
}

#pragma mark - 重写 push 和 pop 方法

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.backgroundImageList addObject:[self screen]];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.backgroundImageList removeLastObject];
    return [super popViewControllerAnimated:animated];
}

#pragma mark - 截屏
- (UIImage*)screen{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - gettrt && setter

- (NSMutableArray *)backgroundImageList
{
    if (_backgroundImageList == nil) {
        _backgroundImageList = [[NSMutableArray alloc] init];
    }
    return _backgroundImageList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
