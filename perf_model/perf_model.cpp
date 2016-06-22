#include <iostream>

void estimation(int N, int M, int R, int C, int K, int S,
                int Tn, int Tm, int Tr, int Tc, int X, int Y,
                int LB, int SB, int f, int opt);

int get_max(int a, int b, int c);

int main(){
    // convoultion design parameters
    int N = 16; // output channel
    int M = 8; // input channel
    int R = 512; // height of feature map
    int C = 512; // width of feature map
    int K = 3;  // kernel size
    //int S = 2;  // stride
    //int opt = 1;

    //int Tn = 16;
    //int Tm = 8;
    //int Tr = 32;
    //int Tc = 66;

    // hardware design parameters
    //int X = 8;
    //int Y = 16;

    int LB = 32/4; // load 1 word per cycle
    int SB = 32/4; // store 1 word per cycle
    float f = 100; // 100MHz

    // No optimization 
    estimation(N, M, R, C, K, 1, 8, 4, 16, 10, 4, 8, LB, SB, f, 0);
    estimation(N, M, R, C, K, 1, 8, 8, 16, 18, 8, 8, LB, SB, f, 0);
    estimation(N, M, R, C, K, 1, 8, 8, 16, 34, 8, 8, LB, SB, f, 0);
    estimation(N, M, R, C, K, 1, 16, 8, 16, 34, 8, 16, LB, SB, f, 0);
    estimation(N, M, R, C, K, 1, 16, 8, 32, 34, 8, 16, LB, SB, f, 0);

    // Optimized
    estimation(N, M, R, C, K, 1, 8, 4, 16, 10, 4, 8, LB, SB, f, 1);
    estimation(N, M, R, C, K, 1, 8, 8, 16, 18, 8, 8, LB, SB, f, 1);
    estimation(N, M, R, C, K, 1, 8, 8, 16, 34, 8, 8, LB, SB, f, 1);
    estimation(N, M, R, C, K, 1, 16, 8, 16, 34, 8, 16, LB, SB, f, 1);
    estimation(N, M, R, C, K, 1, 16, 8, 32, 34, 8, 16, LB, SB, f, 1);
   
}

void estimation(int N, int M, int R, int C, int K, int S,
                int Tn, int Tm, int Tr, int Tc, int X, int Y,
                int LB, int SB, int f, int opt){
    int valid_r = ((R + S - K)/S) * S;
    int valid_c = ((C + S - K)/S) * S;
    int tile_valid_r = ((Tr + S - K)/S) * S;
    int tile_valid_c = ((Tc + S - K)/S) * S;

    int tile_n = (N + Tn - 1)/Tn;
    int tile_m = (M + Tm - 1)/Tm;
    int tile_r = (valid_r + tile_valid_r - 1)/tile_valid_r; 
    int tile_c = (valid_c + tile_valid_c - 1)/tile_valid_c;

    int tile_num = tile_n * tile_m * tile_r * tile_c;

    int weight_tile_size = Tn * Tm * K * K;
    int in_fm_tile_size = Tm * Tr * Tc;
    int out_fm_ld_tile_size = Tn * Tr * Tc;
    int out_fm_st_tile_size = Tn * Tr * Tc;

    int tile_load_cycles = (weight_tile_size + in_fm_tile_size + out_fm_ld_tile_size)/LB;
    int tile_store_cycles = out_fm_st_tile_size/SB;

    // assume each tile can be fully distributed to the physical computing resources.
    int kernel_op_num = K * K;
    int kernel_per_tile = ((Tr + S - K)/S) * ((Tc + S - K)/S) * Tm * Tn;
    int tile_op_num = kernel_per_tile * kernel_op_num;
    int tile_computing_cycles = tile_op_num/(X * Y);

    int load_cycles; 
    int store_cycles; 
    int computing_cycles; 
    float buffer; 
    int total_execution_cycles;

    // No opt at all
    if(opt == 0){
        load_cycles = tile_load_cycles * tile_num;
        store_cycles = tile_store_cycles * tile_num;
        computing_cycles = tile_computing_cycles * tile_num;
        buffer = (weight_tile_size + in_fm_tile_size + out_fm_ld_tile_size)*1.0/1024;
        total_execution_cycles = load_cycles + store_cycles + computing_cycles; 
    }
    // output opt
    else if(opt == 1){
        int weight_size = N * M * K * K; 
        int load_weight_cycles = weight_size/LB;
        store_cycles = tile_store_cycles * tile_num;
        load_cycles = load_weight_cycles + store_cycles;
        computing_cycles = tile_computing_cycles * tile_num;
        buffer = (weight_size + 2*in_fm_tile_size + 2*out_fm_ld_tile_size)*1.0/1024;
        total_execution_cycles = get_max(store_cycles, store_cycles, computing_cycles) + load_weight_cycles; 
    }

    float cycle = 1000.0/f/1000000; // ms
    float total_execution_time = total_execution_cycles * cycle;
    float perf = 1000/total_execution_time;

    //std::cout << "total load time: " << tile_load_time * tile_num << " cycles." << std::endl;
    //std::cout << "total store time: " << tile_store_time * tile_num << " cycles." << std::endl;
    //std::cout << "total computing time: " << tile_computing_time * tile_num << " cycles." << std::endl;
    std::cout << "Minimum on-chip buffer requirement: " << buffer << "K words." <<std::endl;
    std::cout << "Total execution time: " << total_execution_cycles << " cycles. i.e. " << total_execution_time << " ms. " << std::endl;
    std::cout << "Load: computing_time : Store= " << load_cycles * 1.0/computing_cycles << " : 1 : " << store_cycles * 1.0/computing_cycles << std::endl;
    std::cout << "Estimated convoultion performance: " << perf << "fps" << std::endl;
    std::cout << "-------------------------------" << std::endl;
}

int get_max(int a, int b, int c){
    if(a >= b && a >= c){
        return a;
    }
    else if(b >= a && b >= c){
        return b;
    }
    else{
        return c;
    }
}
