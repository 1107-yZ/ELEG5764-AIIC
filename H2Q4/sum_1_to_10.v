`timescale 1ns/1ps
/*
 * 模块: sum_1_to_10
 * 描述: 使用时序逻辑计算 1 到 10 的和 (结果 55).
 * 使用一个 FSM 在 10 个时钟周期内完成计算。
 */
module sum_1_to_10 (
    input             clk,     // 时钟
    input             rst_n,   // 异步复位 (低有效)
    input             start,   // 开始计算信号
    output reg [7:0]  sum_out, // 输出总和 (8位足够存 55)
    output reg        done     // 计算完成信号
);

    // --- 状态机定义 ---
    parameter S_IDLE = 2'b00;  // 空闲状态
    parameter S_CALC = 2'b01;  // 计算状态
    parameter S_DONE = 2'b10;  // 完成状态

    reg [1:0] state, next_state; // 状态寄存器

    // --- 数据路径寄存器 ---
    reg [7:0] sum_reg;     // 累加器
    reg [3:0] index_reg;   // 计数器 (1 到 10, 4位足够)

    // --- 1. 状态转移逻辑 (组合逻辑) ---
    always @(*) begin
        next_state = state; // 默认保持当前状态
        case (state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_CALC;
                end
            end
            S_CALC: begin
                // 当 index_reg 等于 10 时，我们执行最后一次加法
                // 在下一个周期，index_reg 变为 11，此时计算完成
                if (index_reg > 10) begin
                    next_state = S_DONE;
                end
            end
            S_DONE: begin
                // 当 start 信号被撤销后，返回 IDLE
                if (!start) begin
                    next_state = S_IDLE;
                end
            end
            default: next_state = S_IDLE;
        endcase
    end

    // --- 2. 状态寄存器 (时序逻辑) ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // --- 3. 数据路径 (时序逻辑) ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg <= 8'd0;
            index_reg <= 4'd1;
        end else begin
            case (next_state) // 使用 next_state 来避免延迟
                S_IDLE: begin
                    // 重置计数器和累加器
                    sum_reg <= 8'd0;
                    index_reg <= 4'd1;
                end
                S_CALC: begin
                    if (state == S_IDLE) begin
                        // 刚从 IDLE 切换过来，计算第一个数
                        sum_reg <= 4'd1;
                        index_reg <= 4'd2;
                    end else if (state == S_CALC) begin
                        // 迭代计算
                        sum_reg <= sum_reg + index_reg;
                        index_reg <= index_reg + 1;
                    end
                end
                S_DONE: begin
                    // 保持结果，不做任何操作
                end
            endcase
        end
    end

    // --- 4. 输出逻辑 (组合逻辑) ---
    always @(*) begin
        if (state == S_DONE) begin
            sum_out = sum_reg; // 仅在完成状态输出结果
            done = 1'b1;
        end else begin
            sum_out = 8'd0;
            done = 1'b0;
        end
    end

endmodule
