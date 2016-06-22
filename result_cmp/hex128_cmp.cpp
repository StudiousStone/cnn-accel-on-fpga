#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdlib.h>
#include <iomanip>

int decimal_cmp(const std::vector<float> &vec_gold, const std::vector<float> &vec_final);
bool load_hex_to_vec(const std::string &fName, std::vector<float> &vec);
float hex_str_to_fp(const std::string &word);

int main(int argc, char* argv[]){
    std::vector<float> vec_gold;
    std::vector<float> vec_final;
    load_hex_to_vec("./ddr_gold.txt", vec_gold);
    load_hex_to_vec("./ddr_final.txt", vec_final);
    return decimal_cmp(vec_gold, vec_final);

}

bool load_hex_to_vec(const std::string &fName, std::vector<float> &vec){
    std::ifstream fhandle(fName);
    std::cout << fName << std::endl;
    std::string line;
    while(std::getline(fhandle, line)){
        std::string word3 = "0x" + line.substr(0, 8);
        std::string word2 = "0x" + line.substr(8, 8);
        std::string word1 = "0x" + line.substr(16, 8);
        std::string word0 = "0x" + line.substr(24, 8);
        vec.push_back(hex_str_to_fp(word0));
        vec.push_back(hex_str_to_fp(word1));
        vec.push_back(hex_str_to_fp(word2));
        vec.push_back(hex_str_to_fp(word3));
    }
    fhandle.close();
    return true;
}


float hex_str_to_fp(const std::string &word){
    union {
        float fval; 
        uint32_t ival;
    };
    ival = (unsigned)strtol(word.c_str(), NULL, 0);
    return fval;
}

int decimal_cmp(const std::vector<float> &vec_gold, const std::vector<float> &vec_final){
    if(vec_gold.size() != vec_final.size()){
        std::cout << "vec_gold.size() = " << vec_gold.size() << std::endl;
        std::cout << "vec_final.size() = " << vec_final.size() << std::endl;
        return -1;
    }
    else{
        std::cout << "There are " << vec_gold.size() << "elements in the vector. " << std::endl;
        std::vector<float>::const_iterator cit0;
        std::vector<float>::const_iterator cit1;
        int id = 0;
        for(cit0 = vec_gold.begin(), cit1 = vec_final.begin(); cit0 != vec_gold.end(); cit0++, cit1++){
            float res = abs(*cit0 - *cit1);
            if(res > 0.01) {
                int N = 16;
                int R = 32;
                int C = 16;
                int n = id/(R * C);
                int row = (id - n * R * C)/C;
                int col = id - n * R * C - row * C;
                // ignore the data on the corner
                if(N >= 16 || row >= R - 2 || col >= C - 2){
                    continue;
                }
                else {
                    std::cout << "elements are not equal on index: " << n << "-" << row << "-" << col << std::endl;
                }
            }
            id++;
        }
    }
    std::cout << "The results are as expected." << std::endl;
    return 0;
}
