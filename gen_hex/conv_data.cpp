#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <sstream>
#include <cstdint>
#include <stdint.h>
#include <vector>
#include <cmath>

// Parameters of a tile
#define Tn 16
#define Tm 16
#define Tr 64
#define Tc 16
#define K 3
#define S 1

void genHexFile(const std::string &fName, const std::vector<float> &fVec);
std::string fp2Hex(float data);

int main(int argc, char* argv[]) {
    float input_fm[Tm][Tr][Tc];
    float weight[Tn][Tm][K][K];
    float out_fm[Tn][Tr][Tc];

    // Initialize the io data
    init(&input_fm[0][0][0], &weight[0][0][0][0], &out_fm[0][0][0]);

    //Perform the convolution
    for(int to = 0; to < Tn; to++){
        for(int ti = 0; ti < Tm; ti++){
            for(int trr = 0; trr < Tr; trr++){
                for(int tcc = 0; tcc < Tc; tcc++){
                    for(int i = 0; i < K; i++){
                        for(int j = 0; j < K; j++){
                            out_fm[to][trr][tcc] += in_fm[ti][trr][tcc] * weight[to][ti][i][j];
                        }
                    }
                }
            }
        }
    }

}


void genHexFile(const std::string &fName, const std::vector<float> &fVec){

    std::ofstream fhandle (fName.c_str());
    std::vector<float>::const_iterator cit;
    if(fhandle.is_open()){
        int d = 0;
        for (cit = fVec.begin(); cit != fVec.end(); cit++){
            union {float fval; uint32_t ival;};
            fval = *cit;

            std::ostringstream oss;
            oss << std::hex << std::uppercase << ival;
            fhandle << oss.str() << "    "; 
            d++;
            if(d==16){
                fhandle << std::endl;
                d = 0;
            }
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
