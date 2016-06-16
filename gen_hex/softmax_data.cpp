#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <sstream>
#include <cstdint>
#include <stdint.h>
#include <vector>
#include <cmath>

void genHexFile(const std::string &fName, const std::vector<float> &fVec);
std::string fp2Hex(float data);

int main(int argc, char* argv[]) {

    if(argc != 2){
        std::cout << "too many arguments!" << std::endl;
        exit(EXIT_FAILURE);
    }

    int num = std::stoi(argv[1]);
    std::vector<float> iVec;
    std::vector<float> normExp;
    std::vector<float> oProab;
    std::vector<float> zero;
    float sum;

    //init iVec and get max of iVec
    float data = 0;
    float scale = 0;
    for(int i=0; i<num; i++){
        zero.push_back(0.0);
        data += 0.1;
        iVec.push_back(data);
        if(scale < data){
            scale = data;
        }
    }
    genHexFile("zero.txt", zero);
    genHexFile("init.txt", iVec);
    std::cout << "scale = " << fp2Hex(scale) << std::endl;

    //Norm, exp and sum
    sum = 0;
    for(int i=0; i<num; i++){
        data = exp(iVec[i] - scale);
        normExp.push_back(data);
        sum += data;
    }
    genHexFile("normexp.txt", normExp);
    std::cout << "sum = " << fp2Hex(sum) << std::endl;

    // Proability calculation
    for(int i=0; i<num; i++){
        data = normExp[i]/sum;
        oProab.push_back(data);
    }
    genHexFile("proab.txt", oProab);

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
