#include "LayerModel.h"
#include "TSParams.h"

#include <vector>


using namespace std;


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

	
	private:
	vector<vector<float>> initStorage(int size, float startTemp);
	int Nx();
	bool isHeating(int t);

//	ThermalSolver(const ThermalSolver &);
//	ThermalSolver& operator=(const ThermalSolver& obj);
};