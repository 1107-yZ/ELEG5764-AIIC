`timescale 1ns/1ps

module tb_sum;

    localparam CLK_PERIOD = 10; // 10ns 时钟周期

    logic clk;
    logic rst_n;
    logic start;
    wire [7:0] sum_out;
    wire done;

    // 实例化 DUT
    sum_1_to_10 dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .sum_out(sum_out),
        .done(done)
    );

    // 1. 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 2. Verdi 波形生成
    initial begin
        $fsdbDumpfile("sum.fsdb");
        $fsdbDumpvars(0, tb_sum); // dump tb_sum 和它之下的所有信号
    end

    // 3. 激励和测试
    initial begin
        // --- 复位 ---
        rst_n = 1'b0;
        start = 1'b0;
        $display("T=%0t: [Test] 正在复位...", $time);
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        $display("T=%0t: [Test] 复位释放.", $time);
        @(posedge clk);

        // --- 开始计算 ---
        $display("T=%0t: [Test] 拉高 start 信号.", $time);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0; // start 信号只给一个脉冲
        $display("T=%0t: [Test] 拉低 start 信号. 等待 'done'...", $time);

        // --- 等待完成 ---
        // 等待 done 信号变为高电平
        wait (done == 1'b1);
        
        $display("T=%0t: [Test] 'done' 信号已收到!", $time);
        @(posedge clk); // 等待一个周期，让输出稳定

        // --- 检查结果 ---
        if (sum_out == 55) begin
            $display("T=%0t: [SUCCESS] 结果正确! sum_out = %d", $time, sum_out);
        end else begin
            $display("T=%0t: [FAILURE] 结果错误! sum_out = %d, 预期值 55", $time, sum_out);
        end
        
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
