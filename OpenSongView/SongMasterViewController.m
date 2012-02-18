//
//  MasterViewController.m
//  OpenSongMasterDetail
//
//  Created by Andreas Böhrnsen on 1/1/12.
//  Copyright (c) 2012 Open iT Norge AS. All rights reserved.
//

#import "SongMasterViewController.h"

@interface SongMasterViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *allTableData;
@property (strong, nonatomic) NSMutableArray *filteredTableData;
@property (nonatomic) BOOL isFiltered;

- (NSString *)applicationDocumentsDirectory;
- (void)reloadFiles;
@end


@implementation SongMasterViewController

@synthesize allTableData = _allTableData;
@synthesize filteredTableData = _filteredTableData;
@synthesize isFiltered = _isFiltered;

@synthesize delegate = _delegate;


-(NSArray *)allTableData
{
    if(!_allTableData) {
        _allTableData = [NSMutableArray array];
    }
    return _allTableData;
}

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (SongViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [self reloadFiles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.allTableData = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    if(self.isFiltered) {
        rowCount = self.filteredTableData.count;        
    } else {
        if ([self.allTableData count] == 0) {
            rowCount = 1; //we will display a Demo file
        } else {
            rowCount = self.allTableData.count;            
        }
        
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dyncamicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    // display the DemoFile when there is no file transferred yet
    NSURL *fileUrl = nil;
    
    if (self.isFiltered) {
        fileUrl = (NSURL *) [self.filteredTableData objectAtIndex:indexPath.row];
    } else {
        if ([self.allTableData count] == 0) {
            fileUrl = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];
        } else {
            fileUrl = (NSURL *) [self.allTableData objectAtIndex:indexPath.row];
        }        
    }
    cell.textLabel.text = fileUrl.lastPathComponent;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the DemoFile when there is no file transferred yet
    NSURL *fileUrl = nil;
    if ([self.allTableData count] == 0) {
        fileUrl = [[NSBundle mainBundle] URLForResource:@"DemoFile" withExtension:@""];  
    } else {
        fileUrl = (NSURL *) [self.allTableData objectAtIndex:indexPath.row];
    }
    
    [self.delegate songMasterViewControllerDelegate:self choseSong:fileUrl];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchBarDelegate

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = NO;
    }
    else
    {
        self.isFiltered = YES;
        self.filteredTableData = [[NSMutableArray alloc] init];
        
        for (NSURL *fileURL in self.allTableData)
        {
            NSRange nameRange = [fileURL.lastPathComponent rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [fileURL.description rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [self.filteredTableData addObject:fileURL];
            }
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)reloadFiles
{
	[self.allTableData removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator]) {
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		
        // proceed to add the document URL to our list (ignore the "Inbox" folder)
        if (!(isDirectory && [curFileName isEqualToString: @"Inbox"])) {
            [self.allTableData addObject:fileURL];
        }
	}
	    
	[self.tableView reloadData];
}

- (IBAction)refreshList:(id)sender 
// Called when the user taps the Refresh button.
{
#pragma unused(sender)
    [self reloadFiles];
}

@end
