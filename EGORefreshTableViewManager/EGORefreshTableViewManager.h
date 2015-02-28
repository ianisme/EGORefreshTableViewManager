//
//  EGORefreshTableViewManager.h
//  TableViewPull
//
//  Created by ian on 15/2/28.
//  Copyright (c) 2015年 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableView.h"


@protocol EGORefreshTableViewManagerDelegate;

@interface EGORefreshTableViewManager : NSObject<EGORefreshTableDelegate,UITableViewDelegate>
{
    BOOL _reloading;
}
@property(nonatomic,assign)int dataCountOfPerPage;//一页显示数据的个数
@property(nonatomic,assign)int pageNumber;//第几页
@property(nonatomic,assign)int totalDataCount;//总共数据的个数
@property(nonatomic,retain)EGORefreshTableView *refreshTableHeaderView;
@property(nonatomic,retain)EGORefreshTableView *refreshTableFooterView;
@property(nonatomic,assign)UIScrollView *targetView;
@property(nonatomic,assign)id<EGORefreshTableViewManagerDelegate> delegate;
- (id)initWithEGORefreshViewType:(EGORefreshViewType)EGORefreshType andTargetView:(UIScrollView*)targetView;
- (void)pullRefresh;
- (void)doneLoadingTableViewData;
- (void)redisplayRefreshTableFooterView;
- (void)egoRefreshManagerScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshManagerScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)addEGORefreshTableView:(EGORefreshViewType)EGORefreshType toTargetView:(UIScrollView*)targetView;
@end

@protocol EGORefreshTableViewManagerDelegate <NSObject>
//重读数据源的方法,根据刷新功能的类型(EGORefreshViewType)确定如何去重读数据源
- (void)refreshTableViewManager:(EGORefreshTableViewManager*)manager reloadTableViewDataSource:(EGORefreshTableView*)EGORefreshView withType:(EGORefreshViewType)freshViewType;
@end