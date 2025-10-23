`timescale 1ns/1ps

module tb_compare_01;

    logic [3:0] A, B, C;
    wire        RC;
    logic       RC_expected;
    
    // 实例化 DUT
    compare_01 dut (
        .A(A),
        .B(B),
        .C(C),
        .RC(RC)
    );

    // Verdi 波形生成
    initial begin
        $fsdbDumpfile("compare_01.fsdb");
        $fsdbDumpvars(0, tb_compare_01);
    end

    // 辅助任务 (task) 用于施加激励和检查
    task automatic apply_and_check(
        input [3:0] i_A,
        input [3:0] i_B,
        input [3:0] i_C,
        input       i_RC_expected
    );
        // 施加激励
        A = i_A;
        B = i_B;
        C = i_C;
        RC_expected = i_RC_expected;

        // 等待组合逻辑稳定 (在现实中不需要, 但在 testbench 中是好习惯)
        #5; 

        // 检查
        if (RC == RC_expected) begin
            $display("T=%0t: [PASS] A=%d, B=%d, C=%d -> RC=%b (Expected: %b)",
                     $time, A, B, C, RC, RC_expected);
        end else begin
            $error("T=%0t: [FAIL] A=%d, B=%d, C=%d -> RC=%b (Expected: %b)",
                     $time, A, B, C, RC, RC_expected);
        end
        #5; // 保持 5ns 以便看波形
    endtask


    // 激励序列
    initial begin
        $display("--- Simulation Start ---");
        
        // Case 1: N_L=3 (0,2,7), N_G=0.  N_L > N_G. 预期 RC=0
        apply_and_check(4'd0, 4'd2, 4'd7, 1'b0);

        // Case 2: N_L=2 (1,7), N_G=1 (8). N_L > N_G. 预期 RC=0
        apply_and_check(4'd1, 4'd7, 4'd8, 1'b0);
        
        // Case 3: N_L=1 (5), N_G=2 (8, 15). N_L <= N_G. 预期 RC=1
        apply_and_check(4'd5, 4'd8, 4'd15, 1'b1);
        
        // Case 4: N_L=0, N_G=3 (9, 10, 11). N_L <= N_G. 预期 RC=1
        apply_and_check(4'd9, 4'd10, 4'd11, 1'b1);
        
        // 边界 Case: 7, 7, 8. N_L=2, N_G=1. 预期 RC=0
        apply_and_check(4'd7, 4'd7, 4'd8, 1'b0);
        
        // 边界 Case: 7, 8, 8. N_L=1, N_G=2. 预期 RC=1
        apply_and_check(4'd7, 4'd8, 4'd8, 1'b1);

        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule