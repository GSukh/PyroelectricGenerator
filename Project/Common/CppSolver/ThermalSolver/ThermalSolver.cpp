#include "ThermalSolver.h"

#include <stdio.h>

#include <math.h>
#include <time.h>

#include <iostream>
#include <iomanip>

using namespace std;

ThermalSolver::ThermalSolver()
{
	
}


#pragma mark - functions declaration




#pragma mark - public methods

void ThermalSolver::init(void)
{
	buffer = initStorage(2,25.);
//	cout << "buffer size = " << buffer[0].size() << endl;
}

void ThermalSolver::solve(int t)
{
	int layersNumber = (int)layers.size();
	int N = Nx();
	int layerX = N-2;
	for (int l = (layersNumber - 1); l >= 0; l--)
	{
		LayerModel layer = layers[l];
		float dx = layer.dx;
		
		for (int x = layerX; x > (layerX - layer.Nx); x--)
		{
			if (x == 0)
			{
				break;
			}
			
			float coef = layer.tDiffus * (params.dt) / ( dx * dx);
			float dT =  (buffer[0][x+1] - 2 * buffer[0][x] + buffer[0][x-1]);
			buffer[1][x] = dT * coef+ buffer[0][x];
		}
		layerX -= layer.Nx;
	}
	
	// border conditions
	
	LayerModel pztLayer = layers[layersNumber - 1];
	
	if (isHeating(t))
	{
		float dT = ( params.power / params.s / pztLayer.tCond ) * pztLayer.dx;
		buffer[1][N-1] = dT + buffer[1][N-2];
	}
	else
	{
		buffer[1][N-1] = buffer[1][N-2];
	}
	
	buffer[1][0] = buffer[1][1];
//	buffer[1][0] = 25.; //const temperature on the left bourder
	
	int step = 0;
	for (int l = 0; l < layersNumber - 1; l++) {
		LayerModel layer1 = layers[l];
		LayerModel layer2 = layers[l + 1];
		
		step += layer1.Nx;
		
		buffer[1][step] = (layer1.tCond*buffer[1][step-1] + layer2.tCond*(buffer[1][step+1])) / (layer1.tCond + layer2.tCond); //гран усл
		if (step == N-1)
		{
			cout << setprecision(10) << "ERROR  " << buffer[1][step] << endl;			
		}
	}
	
	
	vector<float> newLayer = buffer[1];
	vector<float> clearLayer(N, 0);
	buffer[0] = newLayer;
	buffer[1] = clearLayer;
}

void ThermalSolver::show(void)
{
	int N = Nx();
	for (int i = 0; i < N; i += 2) {
		cout << buffer[0][i] << endl;
	}
}

vector<point> ThermalSolver::data()
{
	vector<point> data;
	
	int lx = 0;
	float ax = 0; //actual x
	for (vector<LayerModel>::iterator it = layers.begin() ; it != layers.end(); ++it)
	{
		for (int x = lx; x < lx + it->Nx; x++) {
			point p;
			p.x = ax;
			p.y = buffer[0][x];
			data.push_back(p);
			
			ax += it->dx;
		}
		lx += it->Nx;
	}
	return data;
}


#pragma mark - private support methods

vector<vector<float>> ThermalSolver::initStorage(int size, float startTemp)
{
	int N = Nx();
	
	vector<vector<float>> data;
	for (int t = 0; t < size; t++)
	{
		vector<float> layer(N,0);
		data.push_back(layer);
	}
	
	
	for (int x = 0; x < N; x++)
	{
		data[0][x] = startTemp;
	}
	
	return data;
}

int ThermalSolver::Nx()
{
	int result = 0;
	for (vector<LayerModel>::iterator it = layers.begin() ; it != layers.end(); ++it)
		result += it->Nx;
	
	return result;
}

bool ThermalSolver::isHeating(int t)
{
	for (int p = 0; p < params.per; p++)
	{
		int startHeatingTime = p * params.Nper + params.NHeatDispl;
		int endHeatingTime = startHeatingTime + params.NHeat;
		if (t >= startHeatingTime && t <= endHeatingTime)
		{
			return true;
		}
	}
	return false;
}

