//
//  EGORefreshTableViewManager.m
//  TableViewPull
//
//  Created by ian on 15/2/28.
//  Copyright (c) 2015年 ian. All rights reserved.
//

//--------------------整合下拉刷新,具体使用方法查看TestEGORefreshViewController中的说明-------------//

#import "EGORefreshTableViewManager.h"
#import "EGORefreshTableView.h"
@implementation EGORefreshTableViewManager

@synthesize dataCountOfPerPage = _dataCountOfPerPage;
@synthesize pageNumber = _pageNumber;
@synthesize totalDataCount = _totalDataCount;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize refreshTableFooterView = _refreshTableFooterView;
@synthesize targetView = _targetView;
@synthesize delegate = _delegate;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(id)init{
    if (self = [super init]) {
        
    }
    return self;
}
//初始化EGORefreshTableViewManager
- (id)initWithEGORefreshViewType:(EGORefreshViewType)EGORefreshType andTargetView:(UIScrollView*)targetView
{
    self = [super init];
    if (self) {

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doneLoadingTableViewData) name:@"EGORefreshViewDoneLoading" object:nil];
        
        [self initEGORefreshTableViewWithEGORefreshType:EGORefreshType andTargetView:targetView];
    }
    return self;
}
/**
 *添加刷新功能
 *EGORefreshType :刷新功能的类型:上拉刷新(EGORefreshViewHeader)或下拉加载更多(EGORefreshViewFooter)或两者都使用(EGORefreshViewHeader + EGORefreshViewFooter)
 *tableView :需要添加刷新功能的tableView
 */
-(void)addEGORefreshTableView:(EGORefreshViewType)EGORefreshType toTargetView:(UIScrollView*)targetView{
    [self initEGORefreshTableViewWithEGORefreshType:EGORefreshType andTargetView:targetView];
}

/**
 *初始化EGORefreshTableView
 */
- (void)initEGORefreshTableViewWithEGORefreshType:(EGORefreshViewType)EGORefreshType andTargetView:(UIScrollView *)targetView {
    if (targetView!=nil) {
        self.targetView = targetView;
        switch (EGORefreshType) {
            case EGORefreshViewHeader:
                self.refreshTableHeaderView = [[EGORefreshTableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - targetView.bounds.size.height, targetView.frame.size.width, targetView.bounds.size.height) Type:EGORefreshViewHeader];
                self.refreshTableFooterView = nil;
                self.refreshTableHeaderView.delegate = self;
                [targetView addSubview:self.refreshTableHeaderView];
                break;
            case EGORefreshViewFooter:
                //                self.refreshTableFooterView = [[[EGORefreshTableView alloc]initWithFrame:CGRectZero]autorelease];
                self.refreshTableFooterView = [[EGORefreshTableView alloc]initWithFrame:CGRectMake(0.0f, targetView.contentSize.height, targetView.frame.size.width, targetView.bounds.size.height) Type:EGORefreshViewFooter];
                self.refreshTableHeaderView = nil;
                self.refreshTableFooterView.delegate = self;
                self.refreshTableFooterView.hidden = YES;
                [targetView addSubview:self.refreshTableFooterView];
                break;
                
            case (EGORefreshViewHeaderAndFooter):
                self.refreshTableHeaderView = [[EGORefreshTableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - targetView.bounds.size.height, targetView.frame.size.width, targetView.bounds.size.height) Type:EGORefreshViewHeader];
                //                self.refreshTableFooterView = [[[EGORefreshTableView alloc]initWithFrame:CGRectZero Type:EGORefreshViewFooter]autorelease];
                
                //开始加载时footer紧贴数据
                self.refreshTableFooterView = [[EGORefreshTableView alloc]initWithFrame:CGRectMake(0.0f, targetView.contentSize.height, targetView.frame.size.width, targetView.bounds.size.height) Type:EGORefreshViewFooter];
                self.refreshTableFooterView.hidden = YES;
                //                //开始加载时footer在tableview的frame的最下方
                //                self.refreshTableFooterView = [[[EGORefreshTableView alloc]initWithFrame:CGRectMake(0.0f,(self.targetView.contentSize.height>self.targetView.frame.size.height?self.targetView.contentSize.height:self.targetView.frame.size.height), 320, self.targetView.frame.size.height) Type:EGORefreshViewFooter]autorelease];
                self.refreshTableHeaderView.delegate = self;
                self.refreshTableFooterView.delegate = self;
                [targetView addSubview:self.refreshTableHeaderView];
                [targetView addSubview:self.refreshTableFooterView];
                
                break;
            default:
                break;
                
        }
    }
}


#pragma mark - UITableViewDelegate
/**
 *显示上拉加载更多的页面
 *此方法的作用是在每次刷新数据后重新调整加载更多的页面(以下称为:RefreshTableFooterView)的位置,根据特定条件判断RefreshTableFooterView是否隐藏,并且将RefreshTableFooterView紧贴在最后一条数据的下方
 */
- (void)redisplayRefreshTableFooterView{
    if (self.refreshTableFooterView) {
        if (_dataCountOfPerPage == 0 || _pageNumber == 0 || _totalDataCount == 0) {
            NSLog(@"如果EGORefreshTableFooterView的显示存在异常，有可能是没有正确设置EGORefreshTableViewManager的成员变量dataCountOfPerPage,pageNumber或totalDataCount");
        }
        if(_dataCountOfPerPage * _pageNumber >= _totalDataCount){
            self.refreshTableFooterView.hidden = YES;
        }else {
            self.refreshTableFooterView.hidden = NO;
        }
        //开始加载时footer紧贴数据
        self.refreshTableFooterView.frame = CGRectMake(0.0f, self.targetView.contentSize.height, self.targetView.frame.size.width, self.targetView.bounds.size.height);
        //开始加载时footer在tableview的frame的最下方
        //        self.refreshTableFooterView.frame = CGRectMake(0.0f,(self.targetView.contentSize.height>self.targetView.frame.size.height?self.targetView.contentSize.height:self.targetView.frame.size.height), 320, self.targetView.frame.size.height);
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource:(EGORefreshTableView*)view{
    if (_delegate && [_delegate respondsToSelector:@selector(refreshTableViewManager:reloadTableViewDataSource:withType:)]) {
        [_delegate refreshTableViewManager:self reloadTableViewDataSource:view withType:view.type];
    }
    _reloading = YES;
}

- (void)doneLoadingTableViewData{
    
    _reloading = NO;
    
    if (self.refreshTableHeaderView && self.targetView) {
        [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.targetView];
        
    }
    if (self.refreshTableFooterView && self.targetView) {
        //调整refreshTableFooterView的位置,并显示
        [self redisplayRefreshTableFooterView];
        [_refreshTableFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.targetView];
        
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
//在你的UITableViewDelegate的scrollViewDidScroll:(UIScrollView *)scrollView中调用
- (void)egoRefreshManagerScrollViewDidScroll:(UIScrollView *)scrollView{
	if (self.refreshTableHeaderView) {
        [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	if (self.refreshTableFooterView) {
        [_refreshTableFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}
//在你的UITableViewDelegate的scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate中调用
- (void)egoRefreshManagerScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (self.refreshTableHeaderView && self.refreshTableHeaderView.hidden == NO) {
        [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	if (self.refreshTableFooterView && self.refreshTableFooterView.hidden == NO) {
        [_refreshTableFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	
}

-(void)pullRefresh{
    if (_refreshTableHeaderView && self.targetView) {
        [_refreshTableHeaderView pullRefresh:self.targetView];
    }
}

#pragma mark -
#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshTableView*)view{
    
    [self reloadTableViewDataSource:view];
    if (self.targetView) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0f];
    }
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(EGORefreshTableView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(EGORefreshTableView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
