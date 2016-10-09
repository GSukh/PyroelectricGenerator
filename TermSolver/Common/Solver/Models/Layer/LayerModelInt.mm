#import "LayerModelInt.h"

#import "CppStructs.h"


@implementation LayerModelInt

- (id)init
{
	self = [super init];
	if (self)
	{
		impl = new LayerImpl;
	}
	return self;
}

- (void)dealloc
{
	delete impl;
}

- (void)show
{
	NSLog(@"height = %f", impl->layer.height);
}


#pragma mark - setters

- (void)setHeight:(float)height
{
	_height = height;
	impl->layer.height = height;
}

- (void)setNx:(int)Nx
{
	_Nx = Nx;
	impl->layer.Nx = Nx;
}

- (void)setThermalConductivity:(float)thermalConductivity
{
	_thermalConductivity = thermalConductivity;
	impl->layer.tCond = thermalConductivity;
}

- (void)setThermalDiffusivity:(float)thermalDiffusivity
{
	_thermalDiffusivity = thermalDiffusivity;
	impl->layer.tDiffus = thermalDiffusivity;
}

- (void)setStartTemp:(float)startTemp
{
	_startTemp = startTemp;
	impl->layer.startTemp = startTemp;
}

- (void)setDx:(float)dx
{
	_dx = dx;
	impl->layer.dx = dx;
}

@end