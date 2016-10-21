#import "TSParamsInt.h"

#import "CppStructs.h"


@implementation TSParamsInt

- (id)init
{
	self = [super init];
	if (self)
	{
		impl = new TSParamsImpl;
	}
	return self;
}

- (void)dealloc
{
	delete impl;
}


#pragma mark - setters

- (void)setDt:(float)dt
{
	_dt = dt;
	impl->params.dt = dt;
}

- (void)setPer:(int)per
{
	_per = per;
	impl->params.per = per;
}

- (void)setNper:(int)Nper
{
	_Nper = Nper;
	impl->params.Nper = Nper;
}

- (void)setNHeat:(int)NHeat
{
	_NHeat = NHeat;
	impl->params.NHeat = NHeat;
}

- (void)setNHeatDispl:(int)NHeatDispl
{
	_NHeatDispl = NHeatDispl;
	impl->params.NHeatDispl = NHeatDispl;
}

- (void)setS:(float)s
{
	_s = s;
	impl->params.s = s;
}

- (void)setPower:(float)power
{
	_power = power;
	impl->params.power = power;
}

@end
