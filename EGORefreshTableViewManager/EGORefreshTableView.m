//
//  EGORefreshTableView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
#define  RefreshViewHeight 40.0f
#import "EGORefreshTableView.h"
//#import "DMConstants.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableView (Private)
- (void)setState:(EGOPullRefreshHeadState)aState;
@end

@implementation EGORefreshTableView
@synthesize type = _type;
@synthesize delegate=_delegate;
@synthesize backgroundView = _backgroundView;

- (id)initWithFrame:(CGRect)frame Type:(EGORefreshViewType)refreshViewType {
    if (self = [super initWithFrame:frame]) {
		_type = refreshViewType;
        
//        self.backgroundColor = [UIColor redColor];
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundView =[[UIImageView alloc]initWithFrame:CGRectMake(0.0, self.frame.size.height-80, self.frame.size.width, 80)];
        UIImage *imgLogo = [UIImage imageNamed:@""];
        self.backgroundView.image = imgLogo;
//        self.backgroundColor = [UIColor colorWithPatternImage:imgLogo];
        [self addSubview:self.backgroundView];
        
//        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-imgLogo.size.width)/2, frame.size.height-60, imgLogo.size.width, imgLogo.size.height) ];
//        [self addSubview:logoView];
//		self.backgroundColor = [UIColor clearColor];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (_type == EGORefreshViewHeader)?frame.size.height - 25.0f:RefreshViewHeight-30.0f, self.frame.size.width, 20.0f)];
//		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = [UIColor blackColor];
//		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
//		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
//		[self addSubview:label];
		_lastUpdatedLabel=label;
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (_type == EGORefreshViewHeader)?frame.size.height - 35.0f:RefreshViewHeight-48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:14.0f];
		label.textColor = [UIColor blackColor];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(87.0f, (_type == EGORefreshViewHeader)?frame.size.height - RefreshViewHeight-5:5, 25.0f, 40.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(87.0f, (_type == EGORefreshViewHeader)?frame.size.height - 35.0f:RefreshViewHeight-38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[self setState:EGOOPullRefreshHeadNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    if ([(EGORefreshTableView*)_delegate respondsToSelector:@selector(egoRefreshTableDataSourceLastUpdated:)]) {
        
        NSDate *date = [_delegate egoRefreshTableDataSourceLastUpdated:self];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setAMSymbol:@"上午"];
        [formatter setPMSymbol:@"下午"];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm"];
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"最后更新: %@", [formatter stringFromDate:date]];
        NSString *string = @"EGOR_LastRefresh";
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:string];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else {
        
//        _lastUpdatedLabel.text = nil;
//        NSString *string = @"EGOR_LastRefresh";
//        NSString *time = NSUser_Defaults_get(string);
//        if(time.length != 0)
//            _lastUpdatedLabel.text = time;
//        else
        _lastUpdatedLabel.text = nil;
    }
    
}

- (void)setState:(EGOPullRefreshHeadState)aState{
	
	switch (aState) {
		case EGOOPullRefreshHeadPulling:
			
			_statusLabel.text = (_type == EGORefreshViewHeader)?NSLocalizedString(@"释放刷新...", @"Release to refresh status"):NSLocalizedString(@"释放开始加载更多...", @"Release to load more");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = (_type == EGORefreshViewHeader)? CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f):CATransform3DIdentity;//(M_PI/180.0)代表极坐标中的顺时针方向一度
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshHeadNormal:
			
			if (_state == EGOOPullRefreshHeadPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = (_type == EGORefreshViewHeader)? CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f):CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = (_type == EGORefreshViewHeader)?NSLocalizedString(@"下拉刷新...", @"Pull down to refresh status"):NSLocalizedString(@"上拉加载更多...", @"Pull up to load more");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = (_type == EGORefreshViewHeader)? CATransform3DIdentity:CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
            
			[self refreshLastUpdatedDate];
			break;
		case EGOOPullRefreshHeadLoading:
			
			_statusLabel.text = NSLocalizedString(@"加载中...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
            
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOOPullRefreshHeadLoading) {
        if (_type == EGORefreshViewHeader) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, 60);
            //TestLog(@"contentOffset is %@",[NSValue valueWithCGPoint:scrollView.contentOffset]);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        }
        if(_type == EGORefreshViewFooter){
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHeight, 0.0f);
        }
    } else if (scrollView.isDragging) {
        
        BOOL _loading = NO;
        if ([(EGORefreshTableView*)_delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
            _loading = [_delegate egoRefreshTableDataSourceIsLoading:self];
        }
        if (_type == EGORefreshViewHeader) {
            if (_state == EGOOPullRefreshHeadPulling && scrollView.contentOffset.y > -RefreshViewHeight && scrollView.contentOffset.y < 0.0f && !_loading) {
                [self setState:EGOOPullRefreshHeadNormal];
            } else if (_state == EGOOPullRefreshHeadNormal && scrollView.contentOffset.y < -RefreshViewHeight && !_loading) {
                [self setState:EGOOPullRefreshHeadPulling];
            }
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
            return;
        }
        if(_type == EGORefreshViewFooter) {
            if (_state == EGOOPullRefreshHeadPulling && scrollView.contentOffset.y + scrollView.frame.size.height < (scrollView.contentSize.height>scrollView.frame.size.height? scrollView.contentSize.height:scrollView.frame.size.height) + RefreshViewHeight && scrollView.contentOffset.y > 0.0f && !_loading) {
                [self setState:EGOOPullRefreshHeadNormal];
            } else if (_state == EGOOPullRefreshHeadNormal && scrollView.contentOffset.y + scrollView.frame.size.height > (scrollView.contentSize.height>scrollView.frame.size.height? scrollView.contentSize.height:scrollView.frame.size.height) + RefreshViewHeight  && !_loading) {
                [self setState:EGOOPullRefreshHeadPulling];
            }
            if (scrollView.contentInset.bottom != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
            return;
        }
    }
    
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    BOOL _loading = NO;
    if ([(EGORefreshTableView*)_delegate respondsToSelector:@selector(egoRefreshTableDataSourceIsLoading:)]) {
        _loading = [_delegate egoRefreshTableDataSourceIsLoading:self];
    }
    
    if (_type == EGORefreshViewHeader) {
        if (scrollView.contentOffset.y <= - RefreshViewHeight && !_loading) {
            if ([(EGORefreshTableView*)_delegate respondsToSelector:@selector(egoRefreshTableDidTriggerRefresh:)]) {
                [_delegate egoRefreshTableDidTriggerRefresh:self];
            }
            [self setState:EGOOPullRefreshHeadLoading];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2f];
            scrollView.contentInset = UIEdgeInsetsMake(RefreshViewHeight, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
        }
        return;
    }
    if(_type == EGORefreshViewFooter){
        if (scrollView.contentOffset.y + scrollView.frame.size.height > (scrollView.contentSize.height>scrollView.frame.size.height? scrollView.contentSize.height:scrollView.frame.size.height) + RefreshViewHeight && !_loading) {
            if ([(EGORefreshTableView*)_delegate respondsToSelector:@selector(egoRefreshTableDidTriggerRefresh:)]) {
                [_delegate egoRefreshTableDidTriggerRefresh:self];
            }
            [self setState:EGOOPullRefreshHeadLoading];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2f];
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHeight, 0.0f);
            [UIView commitAnimations];
        }
        return;
    }
    
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    if (scrollView) {
        [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    
    [UIView commitAnimations];
    [self setState:EGOOPullRefreshHeadNormal];
    
    
}

- (void)pullRefresh:(UIScrollView*)scrollView{
    [UIView animateWithDuration:0.3f animations:^{
        [scrollView setContentOffset:CGPointMake(0, -RefreshViewHeight)];
    } completion:^(BOOL finished) {
        [self egoRefreshScrollViewDidEndDragging:scrollView];
    }];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
}


@end
