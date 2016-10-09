#import "ThermalSolverInt.h"

#import "CppStructs.h"

#import "LayerModelInt.h"
#import "TSParamsInt.h"


@interface ThermalSolverInt ()

@property (nonatomic) NSArray *layers;

@end


@implementation ThermalSolverInt

+(instancetype)sharedTermalSolver
{
	static ThermalSolverInt *solver = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!solver) {
			solver = [[ThermalSolverInt alloc] init];
		}
	});
	
	return solver;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		impl = new ThermalSolverImpl;
	}
	return self;
}

- (void)dealloc
{
	delete impl;
}




#pragma mark - methods
- (void)addLayer:(LayerModelInt *)layer
{
	self.layers = [self.layers arrayByAddingObject:layer];
	impl->solver.layers.push_back(layer->impl->layer);
}

- (void)show
{
	self->impl->solver.show();
}

#pragma mark - C++ methods
- (void)initSolver
{
	impl->solver.init();
}

- (void)solve:(int)t
{
	impl->solver.solve(t);
}


#pragma mark - getters
- (NSArray *)layers
{
	if (!_layers) {
		_layers = [NSArray array];
	}
	return _layers;
}


#pragma mark - setters

- (void)setParams:(TSParamsInt *)params
{
	_params = params;
	impl->solver.params = params->impl->params;
}

@end
