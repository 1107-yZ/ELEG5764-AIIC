`timescale 1ns/1ps

/*
 * 模块: rc_statistic (顶层模块)
 * 描述: 统计 compare_01 模块的输出 (RC) 在256个周期内的结果。
 */
module rc_statistic (
    input             clk,    // 时钟
    input             rst_n,  // 异步复位 (低有效)
    input      [3:0]  A,      // 4位输入 A [0-15]
    input      [3:0]  B,      // 4位输入 B [0-15]
    input      [3:0]  C,      // 4位输入 C [0-15]

    output reg        Vld,    // 有效脉冲信号
    output reg        F       // 统计结果 F
);

    reg  [7:0] cycle_counter_reg; // 8位计数器 (2^8 = 256)
    reg  [8:0] rc1_counter_reg;   // 9位计数器 (用于存储 N1)

    wire       rc_out;            // 存储 RC 结果的线网
    wire       period_end = (cycle_counter_reg == 8'd255);
    wire [8:0] rc1_counter_next;
    
    assign rc1_counter_next = (period_end) ? 9'd0 
                                           : ((rc_out) ? (rc1_counter_reg + 1) 
                                                        : rc1_counter_reg);

    wire [8:0] rc1_count_final_check;
    
    // 如果 rc_out 在周期255上为1，把它加入到计数值中
    assign rc1_count_final_check = (rc_out) ? (rc1_counter_reg + 1) : rc1_counter_reg;

    compare_01 comparator_inst (
        .A(A),      // (d) A, B, C 在每个周期被输入
        .B(B),
        .C(C),
        .RC(rc_out) // (f) 捕获 RC 输出
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_counter_reg <= 8'd0;
            rc1_counter_reg   <= 9'd0;
            Vld               <= 1'b0;
            F                 <= 1'b0;
        end else begin
            
            // 1. 周期计数器自增 (自动从 255 溢出到 0)
            cycle_counter_reg <= cycle_counter_reg + 1;
            
            // 2. RC=1 统计计数器更新
            rc1_counter_reg <= rc1_counter_next;

            if (period_end == 1'b1) begin
                
                Vld <= 1'b1;

                if (rc1_count_final_check > 9'd128) begin
                    F <= 1'b1;
                end else begin
                    F <= 1'b0; // N1 <= 128 (包括 N1 < N0 和 N1 = N0)
                end
                
            end else begin
                
                Vld <= 1'b0;

            end
        end
    end

endmodule