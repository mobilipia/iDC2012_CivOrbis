//
//  CIVOMasterViewController.m
//  Civis Orbis
//
//  Created by Kris Markel on 7/21/12.
//  Copyright (c) 2012 Civis Orbis. All rights reserved.
//

#import "CIVOMasterViewController.h"

#import "City.h"
#import "CIVODetailViewController.h"
#import "iCarousel.h"

@interface CIVOMasterViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@end

@implementation CIVOMasterViewController
@synthesize cityNameLabel;
@synthesize carouselView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Select A City", nil);
    }
    return self;
}
							
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.carouselView.type = iCarouselTypeRotary;
}

- (void)viewDidUnload
{
	[self setCityNameLabel:nil];
	[self setCarouselView:nil];
   [super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// HACK To get the carousel to resize after an orentation change.
	[self.carouselView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.carouselView reloadData];
}

#pragma mark - ICarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
	return [sectionInfo numberOfObjects];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	City *city = (City *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	NSString *smallMapImageName = [NSString stringWithFormat:@"%@-small.jpg", city.mapFile];
	UIImage *mapImage = [UIImage imageNamed:smallMapImageName];
	
	UIImageView *mapImageView = (UIImageView *)view;
	if (!mapImageView) {
		mapImageView = [UIImageView new];
		mapImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	
	float scale = MIN( self.carouselView.bounds.size.width/mapImage.size.width, self.carouselView.bounds.size.height/mapImage.size.height);
	
	mapImageView.bounds = (CGRect) {
		
		.origin = mapImageView.bounds.origin,
		.size.width = mapImage.size.width * scale * 0.9,
		.size.height = mapImage.size.height * scale *0.9,
		
	};
	
	mapImageView.image = mapImage;
	
	return mapImageView;
}



@end
