//
//  SongViewController.m
//  iOpenSongs
//
//  Created by Andreas Böhrnsen on 12/31/11.
//  Copyright (c) 2012 Andreas Boehrnsen. All rights reserved.
//

#import "OSSongViewController.h"

#import "OSSongMasterViewController.h"
#import "OSRevealSidebarController.h"
#import "OSSupportTableViewController.h"

@interface OSSongViewController () <UIWebViewDelegate, OSSongViewDelegate ,OSSupportViewControllerDelegate>
@property (nonatomic, strong) Song *song;
// UI
@property (nonatomic, strong) UIPopoverController *extrasPopoverController;
@property (nonatomic, strong) OSSupportTableViewController *extrasTableViewController;
@end

@implementation OSSongViewController

- (id)initWithSong:(Song *)song
{
    self = [super init];
    if (self) {
        _song = song;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView
{
    OSSongView *songView = [[OSSongView alloc] init];
    songView.delegate = self;
    songView.song = self.song;
    self.view = songView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *revealBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(revealSideMenu:)];
    UIBarButtonItem *supportBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Support" style:UIBarButtonItemStylePlain target:self action:@selector(showSupportInfo:)];
    self.navigationItem.leftBarButtonItems = @[revealBarButtonItem];
    self.navigationItem.rightBarButtonItems = @[supportBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - OSSongViewDelegate

- (void)songView:(OSSongView *)sender didChangeSong:(Song *)song
{
    self.title = song.title;
}

#pragma mark - OSSupportViewControllerDelegate

- (void)supportViewController:(OSSupportTableViewController *)sender willPresentModalViewController:(UIViewController *)controller
{
    [self.extrasPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Actions

- (void)showSupportInfo:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.extrasPopoverController.popoverVisible) {
            [self.extrasPopoverController dismissPopoverAnimated:YES];
        } else {
            [self.extrasPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItems[0]
                                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                 animated:YES];
        }
    } else {
        [self.navigationController pushViewController:self.extrasTableViewController animated:YES];
    }
}

- (void)revealSideMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Private Accessors

- (OSSupportTableViewController *)extrasTableViewController
{
    if (!_extrasTableViewController) {
        _extrasTableViewController = [[OSSupportTableViewController alloc] init];
        _extrasTableViewController.delegate = self;
    }
    return _extrasTableViewController;
}

- (UIPopoverController *)extrasPopoverController
{
    if (!_extrasPopoverController) {
        UINavigationController *extrasNC = [[UINavigationController alloc] initWithRootViewController:self.extrasTableViewController];
        _extrasPopoverController = [[UIPopoverController alloc] initWithContentViewController:extrasNC];
    }
    return _extrasPopoverController;
}

#pragma mark - Public Accessors

- (OSSongView *)songView
{
    return (OSSongView *)self.view;
}

@end
