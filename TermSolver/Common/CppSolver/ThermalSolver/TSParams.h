
class TSParams
{
public:
	float dt;
	int per;
	int Nper;
	int	NHeat;
	int NHeatDispl;
	
	
	float s; //space of heating surface
	float power; //heating power
	
	TSParams();
	TSParams(const TSParams &);
	TSParams& operator=(const TSParams& obj);
};