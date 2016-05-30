#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <sstream>
#include <cstdint>
#include <stdint.h>
#include <vector>
#include <cmath>
#include <iomanip>

// Parameters of a tile
#define N 128
#define M 256
#define R 128
#define C 128
#define Tn 16
#define Tm 16
#define Tr 64
#define Tc 16
#define K 3
#define S 1
#define X 4
#define Y 4

void init(float* const ptr, const int &Num, const float &base);
void genHexFile(const std::string &fName, float* const ptr, const int &Num);
void genDecFile(const std::string &fName, float* const ptr, const int &Num);
void simConvTile(float in_fm[Tm][Tr][Tc], float weight[Tn][Tm][K][K], float out_fm[Tn][Tr][Tc]);
void simConv(float in_fm[M][R][C], float weight[N][M][K][K], float out_fm[N][R][C]);
void goldConv(float in_fm[M][R][C], float weight[N][M][K][K], float out_fm[N][R][C]);
void resultCheck(float out_fm0[N][R][C], float out_fm1[N][R][C]);
std::string fp2Hex(float data);

int main(int argc, char* argv[]) {

    std::cout.precision(5);

    // CNN io
    float in_fm[M][R][C];
    float out_fm[N][R][C];
    float weight[N][M][R][C];

    // Initialize the io data
    init(&in_fm[0][0][0], M * R * C, 0.5);
    init(&weight[0][0][0][0], N * M * K * K, 0.01);
    init(&out_fm0[0][0][0], N * R * C, 0.02);
    init(&out_fm1[0][0][0], N * R * C, 0.02);

    genHexFile("in_fm.txt", &in_fm[0][0][0], M * R * C);
    genHexFile("weight.txt", &weight[0][0][0][0], N * M * K * K);
    genHexFile("out_fm_init.txt", &out_fm0[0][0][0], N * R * C);

    // Golden model
    goldConv(in_fm, weight, out_fm0);

    // Sim model
    simConv(in_fm, weight, out_fm1);

    // Check the result
    resultCheck(out_fm0, out_fm1);

}

// Check if the tiling based design produces correct result.
void resultCheck(float out_fm0[N][R][C], float out_fm1[N][R][C]){

    for(int to = 0; to < N; to++){
        for (int trr = 0; trr < R; trr++){
            for(int tcc = 0; tcc < C; tcc++){
                float sub = out_fm0[to][trr][tcc] - out_fm1[to][trr][tcc];
                if(abs(sub) > 0.01 ){
                    std::cout << "diff_out_fm["<<to <<"][" << trr << "][" << tcc << "] = "
                        << sub << std::endl;
                }
            }
        }
    }

}

void simConv(float in_fm[M][R][C], float weight[N][M][K][K], float out_fm[N][R][C]){

    // tile io
    float in_fm_tile[Tm][Tr][Tc];
    float weight_tile[Tn][Tm][K][K];
    float out_fm_tile[Tn][Tr][Tc];

    for(int tn = 0; tn < N; tn = tn + Y){
        for(int tm = 0; tm < M; tm = tm + X){
            for (int tr = 0; tr < R; tr = tr + Tr){
                for (int tc = 0; tc < C; tc = tc + Tc){
                    simConv(in_fm_tile, weight_tile, out_fm_tile);
                }
            }
        }
    }

    genHexFile("out_fm_sim.txt", &out_fm[0][0][0], N * R * C);
    genDecFile("dec_out_fm_sim.txt", &out_fm[0][0][0], N * R * C);

}

void simConvTile(float in_fm[Tm][Tr][Tc], float weight[Tn][Tm][K][K], float out_fm[Tn][Tr][Tc]){
    // First slice layer
    for(int to = 0; to < Tn; to = to + 4){
        for(int ti = 0; ti < Tm; ti = ti + 4){
            for(int trr = 0; trr <= Tr - K; trr = trr + S){
                for(int tcc = 0; tcc <= Tc - K; tcc = tcc + S){
                    for(int i = 0; i < K; i++){
                        for(int j = 0; j < K; j++){
                            //Data path 0
                            float fmul0 = in_fm[ti][trr+i][tcc+j] * weight[to][ti][i][j];
                            float fmul1 = in_fm[ti+1][trr+i][tcc+j] * weight[to][ti+1][i][j];
                            float fmul2 = in_fm[ti+2][trr+i][tcc+j] * weight[to][ti+2][i][j];
                            float fmul3 = in_fm[ti+3][trr+i][tcc+j] * weight[to][ti+3][i][j];
                            float fadd_L0_0 = fmul0 + fmul1;
                            float fadd_L0_1 = fmul2 + fmul3;
                            float fadd_top = fadd_L0_0 + fadd_L0_1;
                            out_fm[to][trr][tcc] += fadd_top;

                            //Data path 1
                            fmul0 = in_fm[ti][trr+i][tcc+j] * weight[to+1][ti][i][j];
                            fmul1 = in_fm[ti+1][trr+i][tcc+j] * weight[to+1][ti+1][i][j];
                            fmul2 = in_fm[ti+2][trr+i][tcc+j] * weight[to+1][ti+2][i][j];
                            fmul3 = in_fm[ti+3][trr+i][tcc+j] * weight[to+1][ti+3][i][j];
                            fadd_L0_0 = fmul0 + fmul1;
                            fadd_L0_1 = fmul2 + fmul3;
                            fadd_top = fadd_L0_0 + fadd_L0_1;
                            out_fm[to+1][trr][tcc] += fadd_top;

                            //Data path 2
                            fmul0 = in_fm[ti][trr+i][tcc+j] * weight[to+2][ti][i][j];
                            fmul1 = in_fm[ti+1][trr+i][tcc+j] * weight[to+2][ti+1][i][j];
                            fmul2 = in_fm[ti+2][trr+i][tcc+j] * weight[to+2][ti+2][i][j];
                            fmul3 = in_fm[ti+3][trr+i][tcc+j] * weight[to+2][ti+3][i][j];
                            fadd_L0_0 = fmul0 + fmul1;
                            fadd_L0_1 = fmul2 + fmul3;
                            fadd_top = fadd_L0_0 + fadd_L0_1;
                            out_fm[to+2][trr][tcc] += fadd_top;

                            //Data path 3
                            fmul0 = in_fm[ti][trr+i][tcc+j] * weight[to+3][ti][i][j];
                            fmul1 = in_fm[ti+1][trr+i][tcc+j] * weight[to+3][ti+1][i][j];
                            fmul2 = in_fm[ti+2][trr+i][tcc+j] * weight[to+3][ti+2][i][j];
                            fmul3 = in_fm[ti+3][trr+i][tcc+j] * weight[to+3][ti+3][i][j];
                            fadd_L0_0 = fmul0 + fmul1;
                            fadd_L0_1 = fmul2 + fmul3;
                            fadd_top = fadd_L0_0 + fadd_L0_1;
                            out_fm[to+3][trr][tcc] += fadd_top;
                        }
                    }
                    //std::cout << "ti= " << ti << " out_fm["<< to << "][" << trr << "][" << tcc << "] = " << fp2Hex(out_fm[to+3][trr][tcc]) << std::endl;
                }
            }
        }
        //std::cout << " ----------------------------- " << std::endl;
    }
}

void goldConv(float in_fm[M][R][Tc], float weight[N][M][K][K], float out_fm[N][R][C]){
    //Perform the convolution
    for(int to = 0; to < N; to++){
        for(int ti = 0; ti < M; ti++){
            for(int trr = 0; trr <= R - K; trr = trr + S){
                for(int tcc = 0; tcc <= C - K; tcc = tcc + S){
                    for(int i = 0; i < K; i++){
                        for(int j = 0; j < K; j++){
                            out_fm[to][trr][tcc] += in_fm[ti][trr+i][tcc+j] * weight[to][ti][i][j];
                        }
                    }
                }
            }
        }
    } 
    genHexFile("out_fm_gold.txt", &out_fm[0][0][0], N * R * C);
    genDecFile("dec_out_fm_gold.txt", &out_fm[0][0][0], N * R * C);
} 

void init(float* const ptr, const int &Num, const float &base){
    for(int i=0; i<Num; i++){
        *(ptr+i) = base + 0.002 * i;
    }
}

void genDecFile(const std::string &fName, float* const ptr, const int &Num){
    std::ofstream fhandle (fName.c_str());
    if(fhandle.is_open()){
        for (int i=0; i < Num; i++){
            fhandle << *(ptr + i) << std::endl; 
        }
    }
    fhandle.close();
}


void genHexFile(const std::string &fName, float* const ptr, const int &Num){
    std::ofstream fhandle (fName.c_str());
    if(fhandle.is_open()){
        for (int i=0; i < Num; i++){
            union {float fval; uint32_t ival;};
            fval = *(ptr + i);

            std::ostringstream oss;
            oss << std::hex << std::uppercase << ival;
            fhandle << oss.str() << std::endl; 
        }
    }
    fhandle.close();

}

std::string fp2Hex(float data){
    std::ostringstream oss;
    union {float fval; uint32_t ival;};
    fval = data;
    oss << std::hex << std::uppercase << ival;
    return oss.str();
}
