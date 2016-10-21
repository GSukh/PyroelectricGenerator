#import "ViewController.h"

#import "ThermalSolverInt.h"
#import "LayerModelInt.h"
#import "TSParamsInt.h"

#import <CorePlot/osx/CorePlot.h>


@interface ViewController () <CPTPlotDataSource, CPTPlotSpaceDelegate>

@property (weak) IBOutlet CPTGraphHostingView *hostingView;
@property (weak) IBOutlet NSButton *startCalc;
@property (nonatomic) BOOL solving;

@property (nonatomic, strong) CPTGraph *graph;
@property (nonatomic, readwrite, strong, nullable) CPTPlotSpaceAnnotation *zoomAnnotation;

@property (nonatomic) NSMutableArray *data;
@property (nonatomic) CGFloat titleSize;

@property (nonatomic, readwrite, assign) double minimumValueForXAxis;
@property (nonatomic, readwrite, assign) double maximumValueForXAxis;
@property (nonatomic, readwrite, assign) double minimumValueForYAxis;
@property (nonatomic, readwrite, assign) double maximumValueForYAxis;
@property (nonatomic, readwrite, assign) double majorIntervalLengthForX;
@property (nonatomic, readwrite, assign) double majorIntervalLengthForY;

@property (nonatomic, readwrite, assign) CGPoint dragStart;
@property (nonatomic, readwrite, assign) CGPoint dragEnd;

@property (nonatomic, strong) ThermalSolverInt *solver;

@end


#define mm 0.001

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.solver = [[ThermalSolverInt alloc] init];
	
	LayerModelInt *layer1 = [[LayerModelInt alloc] init];
	layer1.height				= 10 * mm;
	layer1.thermalConductivity	= 110.;
	layer1.thermalDiffusivity	= 0.0000343;
	layer1.Nx					= 20;
	layer1.startTemp			= 25.;
	layer1.dx					= 0.000005;
	[self.solver addLayer:layer1];
	
	LayerModelInt *layer2 = [[LayerModelInt alloc] init];
	layer2.height = 1 * mm;
	layer2.thermalConductivity = 2.61;
	layer2.thermalDiffusivity = 0.00000103;
	layer2.Nx = 24;
	layer2.startTemp = 25.;
	layer2.dx = 0.000005;
	[self.solver addLayer:layer2];
	
	TSParamsInt *params = [[TSParamsInt alloc] init];
	params.per = 1;
	params.Nper = 133333333;
	params.NHeat = 66666666;
	params.NHeatDispl = 0;
	params.dt = 0.0000003;
	params.s = 0.0001;
	params.power = 1.;
	self.solver.params = params;
	
	self.titleSize = 24.;
	[self.solver initSolver];
	
	//	[self renderInGraphHostingView:self.hostingView withTheme:nil animated:NO];
	self.minimumValueForXAxis = 0;
	self.maximumValueForXAxis = 0.000005 * 44;
	self.minimumValueForYAxis = 20.;
	self.maximumValueForYAxis = 60.;
	self.majorIntervalLengthForX = 0.000005 * 10;
	self.majorIntervalLengthForY = 10.;
	
	[self createPlot];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

}

#pragma mark - actions

- (IBAction)onStartButtonTap:(NSButton *)sender
{
	if (!self.solving) {
		self.solving = YES;
		
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
		dispatch_async(queue, ^{
			
			for (int i = 0; i < 100000; i++)
			{
				for (int t = i * 500; t < (i + 1)*500; t++) {
					[self.solver solve:t];
				}
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					self.data = [NSMutableArray arrayWithArray:[self.solver data]];
					[self.graph reloadData];
				});
				
				if (!self.solving) {
					break;
				}
			}
			
		});
	}
	else
	{
		self.solving = NO;
	}
}


#pragma mark - plots implementations

- (void) createPlot
{
	CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	
	[newGraph applyTheme:theme];
	self.graph = newGraph;
	
	self.hostingView.hostedGraph = newGraph;
	
	newGraph.paddingLeft   = 0.0;
	newGraph.paddingTop    = 0.0;
	newGraph.paddingRight  = 0.0;
	newGraph.paddingBottom = 0.0;
	
	newGraph.plotAreaFrame.paddingLeft   = 55.0;
	newGraph.plotAreaFrame.paddingTop    = 40.0;
	newGraph.plotAreaFrame.paddingRight  = 40.0;
	newGraph.plotAreaFrame.paddingBottom = 35.0;
	
	newGraph.plotAreaFrame.plotArea.fill = newGraph.plotAreaFrame.fill;
	newGraph.plotAreaFrame.fill          = nil;
	
	newGraph.plotAreaFrame.borderLineStyle = nil;
	newGraph.plotAreaFrame.cornerRadius    = 0.0;
	newGraph.plotAreaFrame.masksToBorder   = NO;
	
	// Setup plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(self.minimumValueForXAxis)
													length:CPTDecimalFromDouble(ceil( (self.maximumValueForXAxis - self.minimumValueForXAxis) / self.majorIntervalLengthForX ) * self.majorIntervalLengthForX)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(self.minimumValueForYAxis)
													length:CPTDecimalFromDouble(ceil( (self.maximumValueForYAxis - self.minimumValueForYAxis) / self.majorIntervalLengthForY ) * self.majorIntervalLengthForY)];
	
	// this allows the plot to respond to mouse events
	plotSpace.delegate = self;
	[plotSpace setAllowsUserInteraction:NO];
	
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
	
	CPTXYAxis *x = axisSet.xAxis;
	x.minorTicksPerInterval = 9;
	x.majorIntervalLength   = CPTDecimalFromDouble(self.majorIntervalLengthForX);
	x.labelOffset           = 5.0;
	x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
	
	CPTXYAxis *y = axisSet.yAxis;
	y.minorTicksPerInterval = 9;
	y.majorIntervalLength   = CPTDecimalFromDouble(self.majorIntervalLengthForY);
	y.labelOffset           = 5.0;
	y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
	
	// Create the main plot for the delimited data
	CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
	dataSourceLinePlot.identifier = @"Data Source Plot";
	
	CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
	lineStyle.lineWidth              = 1.0;
	lineStyle.lineColor              = [CPTColor whiteColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
	
	dataSourceLinePlot.dataSource = self;
	[newGraph addPlot:dataSourceLinePlot];
}

#pragma mark - CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
	return self.data.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSPoint point = [self.data[index] pointValue];
	
	switch (fieldEnum) {
		case CPTRangePlotFieldX:
			return @(point.x);
			break;
			
		case CPTRangePlotFieldY:
			return @(point.y);
			break;
			
		default:
			break;
	}
	return nil;
}

#pragma mark -
#pragma mark Zoom Methods

-(IBAction)zoomIn:(id)sender
{
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
	CPTPlotArea *plotArea     = self.graph.plotAreaFrame.plotArea;
	
	// convert the dragStart and dragEnd values to plot coordinates
	CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];
	CGPoint dragEndInPlotArea   = [self.graph convertPoint:self.dragEnd toLayer:plotArea];
	
	double start[2], end[2];
	
	// obtain the datapoints for the drag start and end
	[plotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
	[plotSpace doublePrecisionPlotPoint:end numberOfCoordinates:2 forPlotAreaViewPoint:dragEndInPlotArea];
	
	// recalculate the min and max values
	self.minimumValueForXAxis = MIN(start[CPTCoordinateX], end[CPTCoordinateX]);
	self.maximumValueForXAxis = MAX(start[CPTCoordinateX], end[CPTCoordinateX]);
	self.minimumValueForYAxis = MIN(start[CPTCoordinateY], end[CPTCoordinateY]);
	self.maximumValueForYAxis = MAX(start[CPTCoordinateY], end[CPTCoordinateY]);
	
	// now adjust the plot range and axes
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(self.minimumValueForXAxis)
													length:CPTDecimalFromDouble(self.maximumValueForXAxis - self.minimumValueForXAxis)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(self.minimumValueForYAxis)
													length:CPTDecimalFromDouble(self.maximumValueForYAxis - self.minimumValueForYAxis)];
	
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
}

-(IBAction)zoomOut:(id)sender
{
	double minX = (double)INFINITY;
	double maxX = -(double)INFINITY;
	
	double minY = (double)INFINITY;
	double maxY = -(double)INFINITY;
	
	// get the ful range min and max values
	for ( NSValue *xyValues in self.data ) {
		NSPoint xyPoint = [xyValues pointValue];
		double xVal = xyPoint.x;
		
		minX = fmin(xVal, minX);
		maxX = fmax(xVal, maxX);
		
		double yVal = xyPoint.y;
		
		minY = fmin(yVal, minY);
		maxY = fmax(yVal, maxY);
	}
	
	double intervalX = self.majorIntervalLengthForX;
	double intervalY = self.majorIntervalLengthForY;
	
	minX = floor(minX / intervalX) * intervalX;
	minY = floor(minY / intervalY) * intervalY;
	
	self.minimumValueForXAxis = minX;
	self.maximumValueForXAxis = maxX;
	self.minimumValueForYAxis = minY;
	self.maximumValueForYAxis = maxY;
	
	// now adjust the plot range and axes
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
	
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minX)
													length:CPTDecimalFromDouble(ceil( (maxX - minX) / intervalX ) * intervalX)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minY)
													length:CPTDecimalFromDouble(ceil( (maxY - minY) / intervalY ) * intervalY)];
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
}




#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
	CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;
	
	if ( annotation ) {
		CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;
		CGRect plotBounds     = plotArea.bounds;
		
		// convert the dragStart and dragEnd values to plot coordinates
		CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];
		CGPoint dragEndInPlotArea   = [self.graph convertPoint:interactionPoint toLayer:plotArea];
		
		// create the dragrect from dragStart to the current location
		CGFloat endX      = MAX( MIN( dragEndInPlotArea.x, CGRectGetMaxX(plotBounds) ), CGRectGetMinX(plotBounds) );
		CGFloat endY      = MAX( MIN( dragEndInPlotArea.y, CGRectGetMaxY(plotBounds) ), CGRectGetMinY(plotBounds) );
		CGRect borderRect = CGRectMake( dragStartInPlotArea.x, dragStartInPlotArea.y,
									   (endX - dragStartInPlotArea.x),
									   (endY - dragStartInPlotArea.y) );
		
		annotation.contentAnchorPoint = CGPointMake(dragEndInPlotArea.x >= dragStartInPlotArea.x ? 0.0 : 1.0,
													dragEndInPlotArea.y >= dragStartInPlotArea.y ? 0.0 : 1.0);
		annotation.contentLayer.frame = borderRect;
	}
	
	return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
	if ( !self.zoomAnnotation ) {
		self.dragStart = interactionPoint;
		
		CPTPlotArea *plotArea       = self.graph.plotAreaFrame.plotArea;
		CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];
		
		if ( CGRectContainsPoint(plotArea.bounds, dragStartInPlotArea) ) {
			// create the zoom rectangle
			// first a bordered layer to draw the zoomrect
			CPTBorderedLayer *zoomRectangleLayer = [[CPTBorderedLayer alloc] initWithFrame:CGRectNull];
			
			CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
			lineStyle.lineColor                = [CPTColor darkGrayColor];
			lineStyle.lineWidth                = 1.0;
			zoomRectangleLayer.borderLineStyle = lineStyle;
			
			CPTColor *transparentFillColor = [[CPTColor blueColor] colorWithAlphaComponent:0.2];
			zoomRectangleLayer.fill = [CPTFill fillWithColor:transparentFillColor];
			
			double start[2];
			[self.graph.defaultPlotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
			NSArray *anchorPoint = @[@(start[CPTCoordinateX]),
									 @(start[CPTCoordinateY])];
			
			// now create the annotation
			CPTPlotSpace *defaultSpace = self.graph.defaultPlotSpace;
			if ( defaultSpace ) {
				CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
				annotation.contentLayer = zoomRectangleLayer;
				self.zoomAnnotation     = annotation;
				
				[self.graph.plotAreaFrame.plotArea addAnnotation:annotation];
			}
		}
	}
	
	return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
	CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;
	
	if ( annotation ) {
		self.dragEnd = interactionPoint;
		
		// double-click to completely zoom out
		if ( event.clickCount == 2 ) {
			CPTPlotArea *plotArea     = self.graph.plotAreaFrame.plotArea;
			CGPoint dragEndInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];
			
			if ( CGRectContainsPoint(plotArea.bounds, dragEndInPlotArea) ) {
				[self zoomOut:nil];
			}
		}
		else if ( !CGPointEqualToPoint(self.dragStart, self.dragEnd) ) {
			// no accidental drag, so zoom in
			[self zoomIn:nil];
		}
		
		// and we're done with the drag
		[self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
		self.zoomAnnotation = nil;
		
		self.dragStart = CGPointZero;
		self.dragEnd   = CGPointZero;
	}
	
	return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
	CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;
	
	if ( annotation ) {
		[self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
		self.zoomAnnotation = nil;
		
		self.dragStart = CGPointZero;
		self.dragEnd   = CGPointZero;
	}
	
	return NO;
}

@end
