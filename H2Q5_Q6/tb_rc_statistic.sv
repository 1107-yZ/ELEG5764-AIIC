`timescale 1ns/1ps

module tb_rc_statistic;

    localparam CLK_PERIOD = 10; // 10ns 时钟

    // --- 信号 ---
    logic             clk;
    logic             rst_n;
    logic      [3:0]  A;
    logic      [3:0]  B;
    logic      [3:0]  C;
    wire              Vld;
    wire              F;

    // --- 实例化 DUT ---
    rc_statistic dut (
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .C(C),
        .Vld(Vld),
        .F(F)
    );

    // 1. 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 2. Verdi 波形
    initial begin
        $fsdbDumpfile("statistic.fsdb");
        // Dump DUT 和 TB 的信号
        $fsdbDumpvars(0, tb_rc_statistic); 
    end

    // 3. 激励和测试
    initial begin
        // --- 复位 ---
        rst_n = 1'b0;
        A = 4'd0;
        B = 4'd0;
        C = 4'd0;
        $display("T=%0t: [Test] 正在复位...", $time);
        // 复位时间要足够长
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        $display("T=%0t: [Test] 复位释放.", $time);
        // **注意：复位释放后，不要等待，立即开始第一个 Case**
        
        // --- Case 1: N1 = 256 (预期 F=1) ---
        // 强制 RC=1 (A=8, B=8, C=8)
        $display("T=%0t: [Case 1] 强制 RC=1 256个周期...", $time);
        A = 4'd8; B = 4'd8; C = 4'd8;
        
        // 等待 256 个周期
        repeat(256) @(posedge clk); 
        
        // **在第256个时钟沿，DUT的Vld变为1，我们立即检查**
        $display("T=%0t: [Case 1] 检查 Vld 和 F...", $time);
        if (Vld == 1'b1 && F == 1'b1) begin
            $display("T=%0t: [PASS] Case 1 (N1=256): Vld=%b, F=%b", $time, Vld, F);
        end else begin
            $error("T=%0t: [FAIL] Case 1 (N1=256): Vld=%b, F=%b. 预期 Vld=1, F=1", $time, Vld, F);
        end
        // **(已删除多余的 @(posedge clk);)**

        // --- Case 2: N1 = 0 (预期 F=0) ---
        // **立即开始 Case 2，以保持与 DUT (cycle=0) 的同步**
        $display("T=%0t: [Case 2] 强制 RC=0 256个周期...", $time);
        A = 4'd0; B = 4'd0; C = 4'd0;
        
        repeat(256) @(posedge clk);
        
        $display("T=%0t: [Case 2] 检查 Vld 和 F...", $time);
        if (Vld == 1'b1 && F == 1'b0) begin
            $display("T=%0t: [PASS] Case 2 (N1=0): Vld=%b, F=%b", $time, Vld, F);
        end else begin
            $error("T=%0t: [FAIL] Case 2 (N1=0): Vld=%b, F=%b. 预期 Vld=1, F=0", $time, Vld, F);
        end
        // **(已删除多余的 @(posedge clk);)**

        // --- Case 3: N1 = 128 (边界, 预期 F=0) ---
        // **立即开始 Case 3**
        $display("T=%0t: [Case 3] 强制 RC 交替 256个周期 (N1=128)...", $time);
        repeat(128) begin // 128 * 2 = 256 周期
            A = 4'd8; B = 4'd8; C = 4'd8; // RC = 1
            @(posedge clk);
            A = 4'd0; B = 4'd0; C = 4'd0; // RC = 0
            @(posedge clk);
        end
        
        $display("T=%0t: [Case 3] 检查 Vld 和 F...", $time);
        if (Vld == 1'b1 && F == 1'b0) begin
            $display("T=%0t: [PASS] Case 3 (N1=128): Vld=%b, F=%b", $time, Vld, F);
        end else begin
            $error("T=%0t: [FAIL] Case 3 (N1=128): Vld=%b, F=%b. 预期 Vld=1, F=0", $time, Vld, F);
        end
        // **(已删除多余的 @(posedge clk);)**

        $display("T=%0t: [Test] 所有测试完成.", $time);
        // 在结束前多等待几个周期，以便在波形中看清楚
        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
