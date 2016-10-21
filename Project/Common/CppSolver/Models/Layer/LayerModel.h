
class LayerModel
{
public:
    float height;
	int Nx;
    float tCond; //thermal conductivity
    float tDiffus; // thermal diffusivity
	
	float startTemp;
	float dx;
	

    LayerModel();
    LayerModel(const LayerModel &);
    LayerModel& operator=(const LayerModel& obj);
};
