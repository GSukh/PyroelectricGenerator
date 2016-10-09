#include "LayerModel.h"

#include <iostream>


LayerModel::LayerModel()
{

}

LayerModel::LayerModel(const LayerModel &obj)
{
    *this = obj;
}

LayerModel& LayerModel::operator = (const LayerModel& obj)
{
    if (this == &obj) {return *this;}
    Nx = obj.Nx;

    height = obj.height;
    tCond = obj.tCond;
    tDiffus = obj.tDiffus;
	startTemp = obj.startTemp;
	dx = obj.dx;
	
    return *this;
}
