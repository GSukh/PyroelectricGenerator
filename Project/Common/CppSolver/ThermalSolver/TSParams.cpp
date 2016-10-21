#include "TSParams.h"

#include <iostream>

TSParams::TSParams()
{
	
}

TSParams::TSParams(const TSParams &obj)
{
	*this = obj;
}

TSParams& TSParams::operator = (const TSParams& obj)
{
	if (this == &obj) {return *this;}
	dt = obj.dt;
	per = obj.per;
	Nper = obj.Nper;
	NHeat = obj.NHeat;
	NHeatDispl = obj.NHeatDispl;
	
	s = obj.s;
	power = obj.power;
	
	return *this;
}