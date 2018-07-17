//
//  SKPanoramaView.m
//  SKPanoramaView
//
//  Created by Sachin Kesiraju on 1/5/15.
//  Copyright (c) 2015 Sachin Kesiraju. All rights reserved.
//

#import "SKPanoramaView.h"

static const CGFloat SKAnimationUpdateInterval = 1 / 100;
static const CGFloat SKPanoramaRotationFactor = 4.0f;

@interface SKPanoramaView ()

@property (nonatomic, assign) CGRect viewFrame;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat motionRate;
@property (nonatomic, assign) NSInteger minimumXOffset;
@property (nonatomic, assign) NSInteger maximumXOffset;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) Boolean *manualStop;

@end

@implementation SKPanoramaView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _viewFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        [self createPanoramaWithImage:image];
    }
    return self;
}

- (void)createPanoramaWithImage:(UIImage *)image
{
    _image = image;

    //Initialize scroll view and add to view
    _scrollView = [[UIScrollView alloc] initWithFrame:_viewFrame];
    [_scrollView setUserInteractionEnabled:NO];
    [_scrollView setBounces:NO];
    [_scrollView setContentSize:CGSizeZero];
//    _scrollView.backgroundColor = UIColor.redColor;
//    _scrollView.scro
    [_scrollView removeFromSuperview];
    [self addSubview:_scrollView];
    
    //Initialize image view and add to scroll view
    CGFloat width = _viewFrame.size.height / _image.size.height * _image.size.width;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, _viewFrame.size.height)];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setImage:_image];
//    [_scrollView removesu]
//    NSLog(@"all the subviews %@", _scrollView.subviews);
    for (UIImageView* each in _scrollView.subviews)
    {
        NSLog(@"i am deleting %@", each);
        [each removeFromSuperview];
    }
    [_scrollView addSubview:imageView];
//    NSLog(@"all the subviews new%@", _scrollView.subviews);

    _scrollView.contentSize = CGSizeMake(imageView.frame.size.width, _scrollView.frame.size.height);
    _motionRate = _image.size.width / _viewFrame.size.width * SKPanoramaRotationFactor;
}

- (void)updatePanoramaWithImage:(UIImage *)image
{
    _image = image;
    
    //Initialize image view and add to scroll view
    CGFloat width = _viewFrame.size.height / _image.size.height * _image.size.width;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, _viewFrame.size.height)];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setImage:_image];
    //    [_scrollView removesu]
    //    NSLog(@"all the subviews %@", _scrollView.subviews);
    for (UIImageView* each in _scrollView.subviews)
    {
        NSLog(@"i am deleting %@", each);
        [each removeFromSuperview];
    }
    
    [_scrollView addSubview:imageView];
    //    NSLog(@"all the subviews new%@", _scrollView.subviews);
    
    _scrollView.contentSize = CGSizeMake(imageView.frame.size.width, _scrollView.frame.size.height);
    _motionRate = _image.size.width / _viewFrame.size.width * SKPanoramaRotationFactor;
}

#pragma mark - Animation

- (void)startAnimating
{
//    if(!_animationSpeed) {
//        _animationSpeed = 10.0f; //Default: 10 seconds for each full panorama transition
//    }
    
    //adjust initial offset based on start position
    if(_startPosition == SKPanoramaStartPositionRight) {
        _scrollView.contentOffset = CGPointMake((_scrollView.contentSize.width - _scrollView.frame.size.width), 0);
    }
    else if(_startPosition == SKPanoramaStartPositionLeft) {
//        _scrollView.contentOffset = CGPointMake(0, 0);
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    
    _minimumXOffset = 0;
    _maximumXOffset = _scrollView.contentSize.width - _scrollView.frame.size.width;
    
    NSLog(@"the offset is %f", _scrollView.contentOffset.x);
//    [UIView animateWithDuration:self.animationSpeed
//                          delay:0.0f
//                        options:UIViewAnimationCurveLinear
//     //                        options:UIViewAnimationOptionRepeat| UIViewAnimationOptionAutoreverse| UIViewAnimationCurveEaseInOut
//                     animations:^{
//                         [_scrollView setContentOffset:CGPointMake(1285, 0) animated:NO];
//                     }
//                     completion:nil];
    CGFloat width = _viewFrame.size.height / _image.size.height * _image.size.width;
    _animationSpeed = (width / [UIScreen mainScreen].bounds.size.width) * 3;
//    self.manualStop = false;
    [UIView animateWithDuration:self.animationSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView setContentOffset:CGPointMake(width - [UIScreen mainScreen].bounds.size.width, 0) animated:NO];
    } completion:^(BOOL finished) {
        self.delegate.SKPanoramaAnimationEnd;

//        if (self.manualStop) {
//        } else {
//            self.delegate.SKPanoramaAnimationEnd;
//        }
    }];
    //    _timer = [NSTimer timerWithTimeInterval:SKAnimationUpdateInterval target:self selector:@selector(transition) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    [self transition];
}

- (void) transition
{
    CGFloat rotationRate = 0.3;
    CGFloat offsetX = _scrollView.contentOffset.x;
    NSLog(@"original offset is %f", offsetX);

    if(_startPosition == SKPanoramaStartPositionRight) {
        offsetX -= rotationRate * _motionRate;
    }
    else if(_startPosition == SKPanoramaStartPositionLeft) {
       offsetX += rotationRate * _motionRate;
    }
    
    if (offsetX > _maximumXOffset) {
        offsetX = _maximumXOffset;
    } else if (offsetX < _minimumXOffset) {
        offsetX = _minimumXOffset;
    }
    
    NSLog(@"offset is %f", offsetX);
    [UIView animateWithDuration:self.animationSpeed
                          delay:0.0f
                        options:UIViewAnimationCurveLinear
//                        options:UIViewAnimationOptionRepeat| UIViewAnimationOptionAutoreverse| UIViewAnimationCurveEaseInOut
                     animations:^{
                         [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
                     }
                     completion:nil];
    

//    [UIView anim]
}

- (void) stopAnimating
{
//    [_timer invalidate];
//    self.manualStop = true;
    [_scrollView.layer removeAllAnimations];
}

@end
