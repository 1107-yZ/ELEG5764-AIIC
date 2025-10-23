`timescale 1ns/1ps

/*
 * 模块: compare_01
 * 描述: 比较 A, B, C 三个4位输入.
 * 如果 <=7 的输入数量 > >=8 的输入数量, RC=0.
 * 否则 RC=1.
 */
module compare_01 (
    input  [3:0] A, // 输入 A (0-15)
    input  [3:0] B, // 输入 B (0-15)
    input  [3:0] C, // 输入 C (0-15)
    output       RC // 输出
);

    // --- 1. 比较器逻辑 ---
    // 我们只需要知道每个输入是 >= 8 还是 <= 7.
    // 对于一个4位无符号数 X, X >= 8 当且仅当 X[3] (MSB) 为 1.
    wire A_G, B_G, C_G;

    // A_G 为 1, 如果 A >= 8 (在 "No Less" 组)
    // A_G 为 0, 如果 A <= 7 (在 "Less" 组)
    assign A_G = A[3];
    assign B_G = B[3];
    assign C_G = C[3];

    // --- 2. 最终输出逻辑 (多数表决电路) ---
    // RC = 1 如果 "No Less" 组 (N_G) 的数量 >= "Less" 组 (N_L) 的数量.
    // 这等价于 N_G >= 2 (即 A_G, B_G, C_G 中至少有两个为 1).
    //
    // 布尔方程: RC = (A_G AND B_G) OR (A_G AND C_G) OR (B_G AND C_G)
    // DC 将把这个 `assign` 语句综合为 3 个 AND 门和 1 个 OR 门.
    assign RC = (A_G & B_G) | (A_G & C_G) | (B_G & C_G);

endmodule