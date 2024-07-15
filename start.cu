#include "cuda_gl_interop.h"
#include "cuda_check_error.h"

#include "SFML/Graphics.hpp"
#include "SFML/Graphics/Image.hpp"

#include <ctime>
#include <iostream>

#include <cuComplex.h>
#include <cuda_runtime.h>
#define _USE_MATH_DEFINES
#include <math.h>

#include <thread>
#include <chrono>

#include <thrust/device_vector.h>
#include <thrust/reduce.h>
#include <thrust/extrema.h>


/*
The Complex Function We Are Visualizing:
f(z)=1.5^z^1.5j
*/

struct ComplexFunctor {
    __device__ cuDoubleComplex operator()(cuDoubleComplex z, double c1, double c2) const {

        if (z.x != 0.0 || z.y != 0.0) {
            cuDoubleComplex base = make_cuDoubleComplex(c1, 0.0);
            cuDoubleComplex exponent = make_cuDoubleComplex(0.0, c2);

            // Calculate z^(2.0j)
            double r = cuCabs(z);
            double theta = atan2(cuCimag(z), cuCreal(z));
            cuDoubleComplex log_z = make_cuDoubleComplex(log(r), theta);
            cuDoubleComplex temp = cuCmul(log_z, exponent);
            cuDoubleComplex z_pow_exponent = make_cuDoubleComplex(exp(temp.x) * cos(temp.y), exp(temp.x) * sin(temp.y));

            // Calculate 1.5^z_pow_exponent
            r = cuCabs(base);
            theta = atan2(cuCimag(base), cuCreal(base));
            log_z = make_cuDoubleComplex(log(r), theta);
            temp = cuCmul(log_z, z_pow_exponent);
            cuDoubleComplex result = make_cuDoubleComplex(exp(temp.x) * cos(temp.y), exp(temp.x) * sin(temp.y));

            return result;
        } else {
            return make_cuDoubleComplex(0.0, 0.0);
        }
        
    }
};

/*
Populating Pixels with Function Outputs
*/

__device__ void populatePixelWithFunctionOutput(cuDoubleComplex *value, double *phase, double *mag, int m, int n, double x, double y, int i, int j, int scale, ComplexFunctor functor, double c1, double c2) {
    double u = x + (i - m / 2.0) * (1.0 / scale);
    double v = y + (j - n / 2.0) * (1.0 / scale);
    cuDoubleComplex z = make_cuDoubleComplex(u, v);
    cuDoubleComplex va = functor(z,c1,c2);

    double ph = atan2(cuCimag(va), cuCreal(va));
    double ma = cuCabs(va);

    value[i * n + j] = va;
    phase[i * n + j] = ph;
    mag[i * n + j] = ma;
}

__global__ void populatePixelWithFunctionOutputKernel(cuDoubleComplex *value, double *phase, double *mag, int m, int n, double x, double y, int scale, ComplexFunctor functor,double c1, double c2) {
    int i0 = blockIdx.x * blockDim.x + threadIdx.x;
    int j0 = blockIdx.y * blockDim.y + threadIdx.y;

    int di = m / (gridDim.x*blockDim.x);
    int dj = n / (gridDim.y*blockDim.y);

    for (int i = i0; i < i0+di; i++){
        for (int j = j0; j < j0+dj; j++){
            populatePixelWithFunctionOutput(value,phase,mag,m,n,x,y,i,j,scale,functor,c1,c2);
        }
    }
}

/*
Populating Pixels with Numerical Derivative of Function
*/
__device__ void populatePixelWithNumericalDerivativeOutput(cuDoubleComplex *value, cuDoubleComplex *dvalue, double *dphase, double* dmag, int m, int n, int i, int j, int scale) 
{

    int idx = i * n + j;

    cuDoubleComplex prev = (i-1 < 0 || j-1 < 0) ? value[idx] : value[(i-1) * n + (j-1)];
    cuDoubleComplex next = (i+1 >= m || j+1 >= n) ? value[idx] : value[(i+1) * n + (j+1)];

    float a = 2.0f * (1.0f / scale);
    float b = 2.0f * (1.0f / scale);

    // Calculate dv
    cuDoubleComplex dv = make_cuDoubleComplex((next.x - prev.x) / std::sqrt(a * a + b * b), 
                                              (next.y - prev.y) / std::sqrt(a * a + b * b));
    
    // Calculate dp using atan2
    double dp = std::atan2(cuCimag(dv), cuCreal(dv));
    
    // Calculate dm as the magnitude of dv
    double dm = cuCabs(dv);

    dvalue[i*n+j]=dv;
    dphase[i*n+j]=dp;
    dmag[i*n+j]=dm;
}

__global__ void populatePixelWithNumericalDerivativeOutputKernel(cuDoubleComplex *value, cuDoubleComplex *dvalue, double *dphase, double *dmag, int m, int n, int scale) {
    int i0 = blockIdx.x * blockDim.x + threadIdx.x;
    int j0 = blockIdx.y * blockDim.y + threadIdx.y;

    int di = m / (gridDim.x*blockDim.x);
    int dj = n / (gridDim.y*blockDim.y);

    for (int i = i0; i < i0+di; i++){
        for (int j = j0; j < j0+dj; j++){
            populatePixelWithNumericalDerivativeOutput(value,dvalue,dphase,dmag,m,n,i,j,scale);
        }
    }
}

/*
Create a finalized HeightMap
def colorbinHeightcontinuousPixel(colorbinHeightcontinuous: np.ndarray, 
                                  phase:np.ndarray, phasemap:np.ndarray, Np:int, maxphase: float, minphase: float, 
                                  dphase:np.ndarray, maxdphase: float, mindphase: float, 
                                  m:int, n:int, i:int, j:int):
    magbinPixel(colorbinHeightcontinuous,phase,m,n,i,j,phasemap,Np,maxphase,minphase)
    colorbinHeightcontinuous[i*n + j]+=((dphase[i*n+j] - mindphase)/(maxdphase-mindphase))

*/

__device__ double magbinPixel(double* mag, double* phase, int m, int n, int i, int j, double* magmap, int Nm, double maxmag, double minmag){
    int idx=(int)(((mag[i*n+j] - minmag)/(maxmag-minmag))*Nm);
    idx=min(Nm-1,idx);
    idx=max(0,idx);
    mag[i*n+j]=magmap[idx];
    mag[i*n+j]=0.0;
}

__device__ void colorbinHeightcontinuousPixel(double* colorbinHeightcontinuous, 
                                                    double* phase, double* phasemap, int Np, double maxphase, double minphase,
                                                    double* dphase, double maxdphase, double mindphase,
                                                    int m, int n, int i, int j) {
    magbinPixel(colorbinHeightcontinuous,phase,m,n,i,j,phasemap,Np,maxphase,minphase);
    colorbinHeightcontinuous[i*n + j]+=((dphase[i*n+j] - mindphase)/(maxdphase-mindphase));
}

__global__ void colorbinHeightcontinuousPixelKernel(double* colorbinHeightcontinuous, 
                                                    double* phase, double* phasemap, int Np, double maxphase, double minphase,
                                                    double* dphase, double maxdphase, double mindphase,
                                                    int m, int n) {
    int i0 = blockIdx.x * blockDim.x + threadIdx.x;
    int j0 = blockIdx.y * blockDim.y + threadIdx.y;

    int di = m / (gridDim.x*blockDim.x);
    int dj = n / (gridDim.y*blockDim.y);

    for (int i = i0; i < i0+di; i++){
        for (int j = j0; j < j0+dj; j++){
            colorbinHeightcontinuousPixel(colorbinHeightcontinuous,phase, phasemap, Np, maxphase, minphase, dphase, maxdphase, mindphase, m, n, i, j);
        }
    }
}

/*
Update GL Texture with image array
*/

// Define an artistic colormap with 20 colors grouped by similarity
__device__ uchar3 artisticColormap[10] = {
   // Blues/Purples/Aquas
        {236.0, 244.0, 214.0},   // Soft Green
        {154.0, 208.0, 194.0},   // Aquamarine
        {45.0, 149.0, 150.0},    // Teal
        {38.0, 80.0, 115.0},     // Deep Sky Blue
        {34.0, 9.0, 44.0},       // Dark Purple
        {135.0, 35.0, 65.0},     // Crimson
        {190.0, 49.0, 68.0},     // Raspberry
        {240.0, 89.0, 65.0},     // Coral
        {7.0, 102.0, 173.0},     // Cobalt Blue
        {41.0, 173.0, 178.0}     // Turquoise
};


// Function to map hue to RGB using artistic colormap
__device__ uchar3 hueToRGB(float hue, double maxphase, double minphase, int Nb) {
    // Calculate the bin index
    int bin = static_cast<int>((hue - minphase) / (maxphase - minphase) * (Nb - 1));

    // Ensure bin index is within bounds
    if (bin < 0) bin = 0;
    if (bin >= Nb) bin = Nb - 1;

    return artisticColormap[bin];
}

__global__ void update_surface_alt(cudaSurfaceObject_t surface, double *value, double* phase, int m, int n, double maxphase, double minphase, int Nb)
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;

    float hue = 255*static_cast<float>(phase[i * n + j]);
    float brighten = 255*static_cast<float>(value[i * n + j]);
    uchar3 rgb = hueToRGB(hue, maxphase, minphase, Nb);

    // Adjust brightness
    int r = static_cast<int>(rgb.x+brighten - 170);
    int g = static_cast<int>(rgb.y+brighten - 170);
    int b = static_cast<int>(rgb.z+brighten - 170);

    // Clamp the values between 0 and 255
    r = min(max(r, 0), 255);
    g = min(max(g, 0), 255);
    b = min(max(b, 0), 255);

    uchar4 pixel = make_uchar4(r, g, b, 0xff);
    surf2Dwrite(pixel, surface, j * sizeof(uchar4), i);
  
}

int main(int argc, char **argv)
{
    int m = 1440;
    int n = 2560;

    //int m = 512;
    //int n = 1024;
    
    sf::RenderWindow window(sf::VideoMode(n,m), "cuda_gl_interop");

    window.setFramerateLimit(60);
    window.setVerticalSyncEnabled(true);


    sf::Sprite sprite;
    sf::Texture txture;
    txture.create(n,m);
    
    cudaArray *bitmap_d;

    GLuint gl_tex_handle = txture.getNativeHandle();

    cudaGraphicsResource *cuda_tex_handle;

    cudaGraphicsGLRegisterImage(&cuda_tex_handle, gl_tex_handle, GL_TEXTURE_2D,
                                cudaGraphicsRegisterFlagsNone);
    cudaCheckError();

    cudaGraphicsMapResources(1, &cuda_tex_handle, 0);
    cudaCheckError();

    cudaGraphicsSubResourceGetMappedArray(&bitmap_d, cuda_tex_handle, 0, 0);
    cudaCheckError();

    struct cudaResourceDesc resDesc;
    memset(&resDesc, 0, sizeof(resDesc));
    resDesc.resType = cudaResourceTypeArray;

    resDesc.res.array.array = bitmap_d;
    cudaSurfaceObject_t bitmap_surface = 0;
    cudaCreateSurfaceObject(&bitmap_surface, &resDesc);
    cudaCheckError();

    sprite.setTexture(txture);

    // Allocate computation memory
    cuDoubleComplex* value;
    double* phase;
    double* mag;
    cudaMalloc(&value,m*n*sizeof(cuDoubleComplex));
    cudaMalloc(&phase,m*n*sizeof(double));
    cudaMalloc(&mag,m*n*sizeof(double));

    cuDoubleComplex* dvalue;
    double* dphase;
    double* dmag;
    cudaMalloc(&dvalue,m*n*sizeof(cuDoubleComplex));
    cudaMalloc(&dphase,m*n*sizeof(double));
    cudaMalloc(&dmag,m*n*sizeof(double));

    double* colorbinHeightcontinuous;
    cudaMalloc(&colorbinHeightcontinuous,m*n*sizeof(double));

    double x = 0.0;
    double y = 0.0;
    int scale = 100;

    int diff=5;

    double c1 = 1.5;
    double c2 = 1.5;

    // Main loop
    while (window.isOpen()) {
        // Event processing
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed) {
                window.close();
            }
        }

        // Check for escape key to exit the loop
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Escape)) {
            window.close();
            break;
        }

        // Move x and y based on key press
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::W)) {
            x -= 5/(double)scale;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::A)) {
            y -= 5/(double)scale;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::S)) {
            x += 5/(double)scale;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::D)) {
            y += 5/(double)scale;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::LShift)) {
            scale*=.99;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::RShift)) {
            scale*=1.01;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Q)) {
            c1+=0.0009;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::E)) {
            c2+=0.0009;
        }
         if (sf::Keyboard::isKeyPressed(sf::Keyboard::R)) {
            c1-=0.0009;
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::T)) {
            c2-=0.0009;
        }
        
        dim3 pixelBlocks (m/32,n/32);
        dim3 pixelBlockSize (32,32);
        ComplexFunctor function;


        populatePixelWithFunctionOutputKernel<<<pixelBlocks,pixelBlockSize>>>(value,phase,mag,m,n,x,y,scale,function, c1, c2);
        cudaDeviceSynchronize();

        populatePixelWithNumericalDerivativeOutputKernel<<<pixelBlocks,pixelBlockSize>>>(value,dvalue,dphase,dmag,m,n,scale);
        cudaDeviceSynchronize();

        thrust::device_ptr<double> phase_ptr(phase);
        thrust::device_vector<double> phase_vector(phase_ptr, phase_ptr + m*n);
        double minphase = *thrust::min_element(phase_vector.begin(), phase_vector.end());
        double maxphase = *thrust::max_element(phase_vector.begin(), phase_vector.end());

        thrust::device_ptr<double> dphase_ptr(dphase);
        thrust::device_vector<double> dphase_vector(dphase_ptr, dphase_ptr + m*n);
        double mindphase = *thrust::min_element(dphase_vector.begin(), dphase_vector.end());
        double maxdphase = *thrust::max_element(dphase_vector.begin(), dphase_vector.end());

        // Output the results
        std::cout << "Minimum phase: " << minphase << std::endl;
        std::cout << "Maximum phase: " << maxphase << std::endl;
        std::cout << "Minimum dphase: " << mindphase << std::endl;
        std::cout << "Maximum dphase: " << maxdphase << std::endl;

        int Np = 10;
        std::vector<double> phasemap(Np);
        for (int i = 0; i < Np; ++i) {
            phasemap[i] = 0.8 * static_cast<double>(i) / Np;
        }
       
        double* phasemapdev;
        cudaMalloc(&phasemapdev,Np*sizeof(double));
        cudaMemcpy(phasemapdev,phasemap.data(),Np*sizeof(double),cudaMemcpyHostToDevice);
        colorbinHeightcontinuousPixelKernel<<<pixelBlocks,pixelBlockSize>>>(colorbinHeightcontinuous,phase,phasemapdev,Np,maxphase,minphase,dphase,maxdphase,mindphase,m,n);
        cudaDeviceSynchronize();

        //update_surface<<<pixelBlocks, pixelBlockSize>>>(bitmap_surface,value,m,n);
        update_surface_alt<<<pixelBlocks, pixelBlockSize>>>(bitmap_surface,colorbinHeightcontinuous,phase,m,n,minphase,maxphase,Np);
        cudaDeviceSynchronize();

        //cudaCheckError();

        
        //cudaCheckError();

    
        window.clear();
        window.draw(sprite);
        window.display();

        printf("frame");
        //std::this_thread::sleep_for(std::chrono::milliseconds(100));
        //diff=(diff+5)%5;
    }

    return 0;
}