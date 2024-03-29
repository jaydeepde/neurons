 /*
 * This sample implements the steerableFilters3D of order 4
 */



#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <cutil_inline.h>
#include "Image.h"
#include "Cube.h"
#include "Mask.h"

// extern "C" void set_horizontal_kernel(vector<float>& kernel);
// extern "C" void set_vertical_kernel(vector<float>& kernel);

extern "C" void setConvolutionKernel_horizontal(float *h_Kernel, int kernel_length);

extern "C" void setConvolutionKernel_vertical(float *h_Kernel, int kernel_length);

extern "C" void setConvolutionKernel_depth(float *h_Kernel, int kernel_length);

extern "C" void convolutionRowsGPU(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int imageD,
    int kernel_radiusw
);

extern "C" void convolutionColumnsGPU(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int imageD,
    int kernel_radius
);

extern "C" void convolutionDepthGPU(
    float *d_Dst,
    float *d_Src,
    int imageW,
    int imageH,
    int imageD,
    int kernel_radius
);


extern "C" void hessianGPU
(
 float *d_output,
 float *d_gxx,
 float *d_gxy,
 float *d_gxz,
 float *d_gyy,
 float *d_gyz,
 float *d_gzz,
 float sigma,
 int imageW,
 int imageH,
 int imageD
 );


extern "C" void hessianGPU_orientation
(
 float *d_output,
 float *d_output_theta,
 float *d_output_phi,
 float *d_gxx,
 float *d_gxy,
 float *d_gxz,
 float *d_gyy,
 float *d_gyz,
 float *d_gzz,
 float sigma,
 int imageW,
 int imageH,
 int imageD
 );


extern "C" void set_horizontal_kernel(vector<float>& kernel){
  float h_kernel_h[kernel.size()];
  for(unsigned int i = 0; i < kernel.size(); i++)
    h_kernel_h[i] = kernel[i];
  setConvolutionKernel_horizontal(h_kernel_h, kernel.size());
}

extern "C" void set_vertical_kernel(vector<float>& kernel){
  float h_kernel_h[kernel.size()];
  for(unsigned int i = 0; i < kernel.size(); i++)
    h_kernel_h[i] = kernel[i];
  setConvolutionKernel_vertical(h_kernel_h, kernel.size());
}

extern "C" void set_depth_kernel(vector<float>& kernel){
  float h_kernel_h[kernel.size()];
  for(unsigned int i = 0; i < kernel.size(); i++)
    h_kernel_h[i] = kernel[i];
  setConvolutionKernel_depth(h_kernel_h, kernel.size());
}


extern "C" void convolution_separable
( float* d_Dst,
  float* d_Src,
  vector< float >& kernel_h,
  vector< float >& kernel_v,
  vector< float >& kernel_d,
  int sizeX,
  int sizeY,
  int sizeZ,
  float* d_tmp
  )
{
  set_horizontal_kernel(kernel_h);
  set_vertical_kernel  (kernel_v);
  set_depth_kernel     (kernel_d);

  cutilSafeCall( cudaThreadSynchronize() );
  convolutionRowsGPU(d_Dst,
                     d_Src,
                     sizeX,
                     sizeY,
                     sizeZ,
                     floor(kernel_h.size()/2)
                     );

  convolutionColumnsGPU(
                        d_tmp,
                        d_Dst,
                        sizeX,
                        sizeY,
                        sizeZ,
                        floor(kernel_v.size()/2)
                        );

  convolutionDepthGPU(
                        d_Dst,
                        d_tmp,
                        sizeX,
                        sizeY,
                        sizeZ,
                        floor(kernel_d.size()/2)
                        );

  cutilSafeCall( cudaThreadSynchronize() );
}


extern "C" void hessian
( float* d_Buffer,
  float* d_Input,
  float sigma,
  float *d_gxx,
  float *d_gxy,
  float *d_gxz,
  float *d_gyy,
  float *d_gyz,
  float *d_gzz,
  int sizeX,
  int sizeY,
  int sizeZ
  )
{

  vector<float> kernel_0 = Mask::gaussian_mask(0, sigma, 1);
  vector<float> kernel_1 = Mask::gaussian_mask(1, sigma, 1);
  vector<float> kernel_2 = Mask::gaussian_mask(2, sigma, 1);

  convolution_separable( d_gxx, d_Input, kernel_2, kernel_0, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gxy, d_Input, kernel_1, kernel_1, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gxz, d_Input, kernel_1, kernel_0, kernel_1,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gyy, d_Input, kernel_0, kernel_2, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gyz, d_Input, kernel_0, kernel_1, kernel_1,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gzz, d_Input, kernel_0, kernel_0, kernel_2,
                         sizeX, sizeY, sizeZ, d_Buffer );

  hessianGPU(d_Buffer, d_gxx, d_gxy, d_gxy, d_gyy, d_gyz, d_gzz, sigma, sizeX, sizeY, sizeZ);
}


extern "C" void hessian_orientation
( float* d_Buffer,
  float* d_Output_theta,
  float* d_Output_phi,
  float* d_Input,
  float sigma,
  float *d_gxx,
  float *d_gxy,
  float *d_gxz,
  float *d_gyy,
  float *d_gyz,
  float *d_gzz,
  int sizeX,
  int sizeY,
  int sizeZ
  )
{

  vector<float> kernel_0 = Mask::gaussian_mask(0, sigma, 1);
  vector<float> kernel_1 = Mask::gaussian_mask(1, sigma, 1);
  vector<float> kernel_2 = Mask::gaussian_mask(2, sigma, 1);

  convolution_separable( d_gxx, d_Input, kernel_2, kernel_0, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gxy, d_Input, kernel_1, kernel_1, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gxz, d_Input, kernel_1, kernel_0, kernel_1,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gyy, d_Input, kernel_0, kernel_2, kernel_0,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gyz, d_Input, kernel_0, kernel_1, kernel_1,
                         sizeX, sizeY, sizeZ, d_Buffer );
  convolution_separable( d_gzz, d_Input, kernel_0, kernel_0, kernel_2,
                         sizeX, sizeY, sizeZ, d_Buffer );

  // printf("H orientation: o: %i, t: %i p: %i\n",
         // d_Buffer, d_Output_theta, d_Output_phi);
  hessianGPU_orientation
    (d_Buffer, d_Output_theta, d_Output_phi,
     d_gxx, d_gxy, d_gxy, d_gyy, d_gyz, d_gzz,
     sigma, sizeX, sizeY, sizeZ);
}



////////////////////////////////////////////////////////////////////////////////
// Main program
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv){

  if(argc!=4){
    printf("Usage: cubeHessian volume.nfo sigma out\n");
    exit(0);
  }

  float
    *h_Input,
    *h_OutputGPU,
    *h_OutputGPU_phi,
    *h_OutputGPU_theta;

  float
    *d_Input,
    *d_Output,
    *d_Output_theta,
    *d_Output_phi,
    *d_gxx, *d_gxy, *d_gxz, *d_gyy, *d_gyz, *d_gzz
    ;

  printf("Initializing CUDA\n");
  unsigned int hTimer;
  cudaSetDevice( cutGetMaxGflopsDeviceId() );
  cutilCheckError(cutCreateTimer(&hTimer));


  printf("Initializing image and result image\n");
  Cube<uchar, ulong>*  cube = new Cube<uchar, ulong>(argv[1]);
  float sigma = atof(argv[2]);
  Cube<float, double>* res = cube->create_blank_cube(argv[3]);
  string nameTheta(argv[3]); nameTheta = nameTheta + "_theta";
  string namePhi(argv[3]);   namePhi = namePhi + "_phi";
  Cube<float, double>* res_theta = res->create_blank_cube(nameTheta);
  Cube<float, double>* res_phi   = res_theta->create_blank_cube(namePhi);
  int imageW = cube->cubeWidth;
  int imageH = cube->cubeHeight;
  int imageD = cube->cubeDepth;
  const int maxTileSizeX = 256;
  const int maxTileSizeY = 256;
  const int maxTileSizeZ = 124;
  int  maxLinearSize = maxTileSizeX * maxTileSizeY * maxTileSizeZ;

  printf("Allocating and intializing host arrays...\n");
  h_Input     = (float *)malloc( maxLinearSize * sizeof(float));
  h_OutputGPU = (float *)malloc( maxLinearSize * sizeof(float));
  h_OutputGPU_theta = (float *)malloc( maxLinearSize * sizeof(float));
  h_OutputGPU_phi   = (float *)malloc( maxLinearSize * sizeof(float));
  srand(200);

  printf("Allocating CUDA arrays...\n");
  cutilSafeCall( cudaMalloc((void **)&d_Input,        maxLinearSize * sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_Output,       maxLinearSize * sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_Output_theta, maxLinearSize * sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_Output_phi,   maxLinearSize * sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gxx,          maxLinearSize *sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gxy,   maxLinearSize *sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gxz,   maxLinearSize *sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gyy,   maxLinearSize *sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gyz,   maxLinearSize *sizeof(float)) );
  cutilSafeCall( cudaMalloc((void **)&d_gzz,   maxLinearSize *sizeof(float)) );

  // Here should come the loop
  // Variables required to split the image into tiles
  vector< float > kernelSample = Mask::gaussian_mask(0, sigma, 1);
  int pad_x = ceil(kernelSample.size()/2);
  int pad_y = ceil(kernelSample.size()/2);
  int pad_z = ceil(kernelSample.size()/2);
  int tile_size_x  = maxTileSizeX - 2*pad_x;
  int tile_size_y  = maxTileSizeY - 2*pad_y;
  int tile_size_z  = maxTileSizeZ - 2*pad_z;
  int n_tiles_horiz = ceil(float(imageW) /tile_size_x);
  int n_tiles_vert  = ceil(float(imageH) /tile_size_y);
  int n_tiles_depth = ceil(float(imageD) /tile_size_z);

  printf("Sigma = %f, kernel size: %i, Tiles pads be: [%i,%i,%i]\n",
         sigma, kernelSample.size(), pad_x, pad_y, pad_z);

  printf("Tiles sizes be: [%i,%i,%i]\n",
         tile_size_x, tile_size_y, tile_size_z);


  printf("The number of tiles should be: [%i,%i,%i]\n",
         n_tiles_horiz, n_tiles_vert, n_tiles_depth);

  vector<float> kernel_0 = Mask::gaussian_mask(0, sigma, 1);
  vector<float> kernel_1 = Mask::gaussian_mask(1, sigma, 1);
  vector<float> kernel_2 = Mask::gaussian_mask(2, sigma, 1);

  // for the tiles in horizontal
  for(int tz = 0; tz < n_tiles_depth; tz++){
    for(int ty = 0; ty < n_tiles_vert; ty++){
      for(int tx = 0; tx < n_tiles_horiz; tx++){

        int x0, y0, z0, x1, y1, z1;
        x0 = tx*tile_size_x;
        y0 = ty*tile_size_y;
        z0 = tz*tile_size_z;
        x1 = min((tx+1)*tile_size_x -1, imageW-1);
        y1 = min((ty+1)*tile_size_y -1, imageH-1);
        z1 = min((tz+1)*tile_size_z  -1, cube->cubeDepth -1);
        printf(" iteration [%i,%i,%i], pad= [%i,%i,%i]->[%i,%i,%i]\n",
               tx, ty, tz, x0, y0, z0, x1, y1, z1);

        Cube<uchar, ulong>* padded =
          cube->get_padded_tile(x0, y0, z0, x1, y1, z1, pad_x, pad_y, pad_z);

        // puts the padded image into the array where the convolutions are going to be done
        for(int z = 0; z < padded->cubeDepth; z++)
          for(int y = 0; y < padded->cubeHeight; y++)
            for(int x = 0; x < padded->cubeWidth; x++)
              h_Input[(z*maxTileSizeX + y)*maxTileSizeY + x] = padded->at(x,y,z);

        cutilSafeCall( cudaMemcpy(d_Input, h_Input,
                                  maxLinearSize * sizeof(float),
                                  cudaMemcpyHostToDevice) );

        // printf("Main loop: o: %i, t: %i p: %i\n",
               // d_Output, d_Output_theta, d_Output_phi);
        hessian_orientation
          (d_Output, d_Output_theta, d_Output_phi,
           d_Input, sigma,
           d_gxx, d_gxy, d_gxz, d_gyy, d_gyz, d_gzz,
           maxTileSizeX, maxTileSizeY, maxTileSizeZ);
        // hessian
          // (d_Output,
           // d_Input, sigma,
           // d_gxx, d_gxy, d_gxz, d_gyy, d_gyz, d_gzz,
           // maxTileSizeX, maxTileSizeY, maxTileSizeZ);


        cutilSafeCall( cudaThreadSynchronize() );

        cutilSafeCall( cudaMemcpy(h_OutputGPU, d_Output,
                                  maxLinearSize * sizeof(float),
                                  cudaMemcpyDeviceToHost) );
        cutilSafeCall( cudaMemcpy(h_OutputGPU_theta, d_Output_theta,
                                  maxLinearSize * sizeof(float),
                                  cudaMemcpyDeviceToHost) );
        cutilSafeCall( cudaMemcpy(h_OutputGPU_phi, d_Output_phi,
                                  maxLinearSize * sizeof(float),
                                  cudaMemcpyDeviceToHost) );


        for(int z = pad_z; z < padded->cubeDepth-pad_z; z++)
          for(int y = pad_y; y < padded->cubeHeight-pad_y; y++)
            for(int x = pad_x; x < padded->cubeWidth-pad_x; x++){
              res->put(x0+x-pad_x, y0+y-pad_y, z0+z-pad_z,
                     h_OutputGPU[(z*maxTileSizeY + y)*maxTileSizeX + x]);
              res_theta->put(x0+x-pad_x, y0+y-pad_y, z0+z-pad_z,
                             h_OutputGPU_theta[(z*maxTileSizeY + y)*maxTileSizeX + x]);
              res_phi->put(x0+x-pad_x, y0+y-pad_y, z0+z-pad_z,
                             h_OutputGPU_phi[(z*maxTileSizeY + y)*maxTileSizeX + x]);
            }

        delete padded;
      }
    }
  }
  printf("Done with the computations\n");


  printf("Shutting down...\n");
  cutilSafeCall( cudaFree(d_Input) );
  cutilSafeCall( cudaFree(d_Output) );
  cutilSafeCall( cudaFree(d_Output_theta) );
  cutilSafeCall( cudaFree(d_Output_phi) );
  cutilSafeCall( cudaFree(d_gxx ) );
  cutilSafeCall( cudaFree(d_gxy ) );
  cutilSafeCall( cudaFree(d_gxz ) );
  cutilSafeCall( cudaFree(d_gyy ) );
  cutilSafeCall( cudaFree(d_gyz ) );
  cutilSafeCall( cudaFree(d_gzz ) );

  free(h_OutputGPU);
  free(h_OutputGPU_theta);
  free(h_OutputGPU_phi);
  free(h_Input);

  cutilCheckError(cutDeleteTimer(hTimer));

  cudaThreadExit();

  exit(0);
}

