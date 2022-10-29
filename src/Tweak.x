#import "../headers/HeadersTweak.h"

Velvet2PrefsManager *prefsManager;

%hook NCNotificationShortLookViewController
%property (nonatomic,retain) UIView *velvetView;

-(void)viewDidLoad {
    %orig;

    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;

    UIView *velvetView = [UIView new];
    [velvetView.layer insertSublayer:[CAGradientLayer layer] atIndex:0];
    [view.backgroundMaterialView.superview insertSubview:velvetView atIndex:1];

    self.velvetView = velvetView;
    self.velvetView.clipsToBounds = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}

-(void)viewDidLayoutSubviews {
    %orig;

    if (self.viewForPreview.frame.size.width == 0) return;

    [self velvetUpdateStyle];
}

%new
-(void)velvetUpdateStyle {
    NSString *identifier = self.notificationRequest.sectionIdentifier;

    // Initialize content variables
    NCNotificationShortLookView *view                       = (NCNotificationShortLookView *)self.viewForPreview;
    MTMaterialView *materialView                            = view.backgroundMaterialView;
    NCNotificationViewControllerView *controllerView        = [self valueForKey:@"contentSizeManagingView"];
    UIView *stackDimmingView                                = [controllerView valueForKey:@"stackDimmingView"];
    // CAGradientLayer *singleBorder                           = self.velvetView.layer.sublayers[0];
    NCNotificationSeamlessContentView *contentView          = [view valueForKey:@"notificationContentView"];
    // UILabel *title                                          = [contentView valueForKey:@"primaryTextLabel"];
    // UILabel *message                                     = [contentView valueForKey:@"secondaryTextElement"];
    // UILabel *dateLabel                                   = [contentView valueForKey:@"dateLabel"];
    NCBadgedIconView *badgedIconView                        = [contentView valueForKey:@"badgedIconView"];
    UIImageView *appIconView                                = (UIImageView *)badgedIconView.iconView;

    self.velvetView.frame = materialView.frame;

    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:identifier];
    colorizer.appIcon = appIconView.image;
    
    // =============== Corner Radius =============== //

    CGFloat cornerRadius = [[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:identifier] boolValue] ? [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:identifier] floatValue] : 19;
	materialView.layer.continuousCorners = cornerRadius < materialView.frame.size.height / 2;
	materialView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    self.velvetView.layer.continuousCorners = cornerRadius < self.velvetView.frame.size.height / 2;
	self.velvetView.layer.cornerRadius = MIN(cornerRadius, self.velvetView.frame.size.height / 2);

    view.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    materialView.superview.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    stackDimmingView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);

    // =============== Background =============== //

    [colorizer colorBackground:self.velvetView];

    // =============== Border =============== //

    [colorizer colorBorder:self.velvetView];

    // Single border
    // singleBorder.frame = CGRectMake(0, materialView.frame.size.height - 3, materialView.frame.size.width, 3);
    // singleBorder.backgroundColor = gradientColor.CGColor;

    // Shadow
	// materialView.layer.shadowOpacity = 0.75;
	// materialView.layer.shadowOffset = CGSizeZero;
	// materialView.layer.shadowRadius = 5;
	// materialView.layer.shadowColor = UIColor.whiteColor.CGColor;

    // Title
    // title.textColor = gradientColor;

    // Message
    // message.textColor = customColor;
    // message.textAlignment = NSTextAlignmentCenter;

    // Date
    // dateLabel.textColor = UIColor.redColor;
    // dateLabel.layer.filters = nil;

    // Icon
    // appIcon.layer.cornerRadius = 19;
    // appIcon.clipsToBounds = YES;
}
%end

%hook NCNotificationStructuredListViewController
-(void)viewDidLoad {
    %orig;
    // self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
}
%end

%ctor {
    prefsManager = [NSClassFromString(@"Velvet2PrefsManager") sharedInstance];

    if ([[prefsManager objectForKey:@"enabled"] boolValue]) {
        %init;
    }
}