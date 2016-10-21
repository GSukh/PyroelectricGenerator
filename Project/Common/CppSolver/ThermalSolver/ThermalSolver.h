#include "LayerModel.h"
#include "TSParams.h"

#include <vector>


using namespace std;

struct point{
	float x;
	float y;
};


class ThermalSolver
{
public:
	vector<vector<float>> storage;
	vector<vector<float>> buffer;
	
	vector<LayerModel> layers;
	
	TSParams params;
	
	
	ThermalSolver();
	void init();
	void solve(int t);
	void show();
	
	vector<point> data();


	
	private:
	vector<vector<float>> initStorage(int size, float startTemp);
	bool isHeating(int t);
	int Nx();

//	ThermalSolver(const ThermalSolver &);
//	ThermalSolver& operator=(const ThermalSolver& obj);
};