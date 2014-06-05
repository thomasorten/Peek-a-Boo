#import "MasterViewController.h"
#import "AddUserViewController.h"
#import "ImageCollectionViewCell.h"
#import "User.h"

@interface MasterViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property int screenWidth;
@property int screenHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"UserCache"];
    [self.fetchedResultsController performFetch:nil];

    self.fetchedResultsController.delegate = self;

    if (!self.fetchedResultsController.fetchedObjects.count) {
        [self downloadPhotosByTerm:@"people"];
    }
}

- (void)downloadFromUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSManagedObject *userObject = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
        [userObject setValue:data forKeyPath:@"photo"];
        [self.managedObjectContext save:nil];
    }];
}

- (void)downloadPhotosByTerm:(NSString *)searchTerm
{
    NSString *searchString = [NSString stringWithFormat:@"https://api.500px.com/v1/photos/search?term=%@&rpp=24&consumer_key=rBKpV9WPCBNXBc6LKwfCU8Dv6TFKk0eDcm1I7Dhw", searchTerm];
    NSURL *url = [NSURL URLWithString:searchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *images = [json objectForKey:@"photos"];
        for (NSDictionary *imageDictionary in images) {
            NSString *imageUrl = [imageDictionary objectForKey:@"image_url"];
            [self downloadFromUrl:imageUrl];
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];

    cell.imageView.image = [UIImage imageWithData:user.photo];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self.flowLayout setSectionInset:UIEdgeInsetsZero];
    [self.flowLayout setItemSize:CGSizeMake(self.screenWidth-50, self.screenHeight-100)];
    [self.flowLayout invalidateLayout];
    [collectionView reloadData];
    [cell.imageView sizeToFit];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;
}

@end