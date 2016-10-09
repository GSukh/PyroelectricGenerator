#import "ViewController.h"

#import "ThermalSolverInt.h"
#import "LayerModelInt.h"
#import "TSParamsInt.h"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}


#pragma mark - actions

#define mm 0.001

- (IBAction)onStartButtonTap:(id)sender
{
	ThermalSolverInt *solver = [[ThermalSolverInt alloc] init];
	
	LayerModelInt *layer1 = [[LayerModelInt alloc] init];
	layer1.height				= 10 * mm;
	layer1.thermalConductivity	= 110.;
	layer1.thermalDiffusivity	= 0.0000343;
	layer1.Nx					= 20;
	layer1.startTemp			= 25.;
	layer1.dx					= 0.000005;
	[solver addLayer:layer1];
	
	LayerModelInt *layer2 = [[LayerModelInt alloc] init];
	layer2.height = 1 * mm;
	layer2.thermalConductivity = 2.61;
	layer2.thermalDiffusivity = 0.00000103;
	layer2.Nx = 24;
	layer2.startTemp = 25.;
	layer2.dx = 0.000005;
	[solver addLayer:layer2];

	TSParamsInt *params = [[TSParamsInt alloc] init];
	params.per = 1;
	params.Nper = 133333333;
	params.NHeat = 66666666;
	params.NHeatDispl = 0;
	params.dt = 0.0000003;
	params.s = 0.0001;
	params.power = 1.;
	solver.params = params;
	
	[solver initSolver];
	
	for (int t = 0; t < 1000; t++)
	{
		[solver solve:t];
		if (t%100 == 0) {
			[solver show];
		}
	}
}

@end
