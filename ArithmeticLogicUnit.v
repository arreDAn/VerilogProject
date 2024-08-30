// ALU with all operations in a single file

// Parameterized AND
module and_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = a & b;
endmodule

// Parameterized NAND
module nand_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = ~(a & b);
endmodule

// Parameterized OR
module or_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = a | b;
endmodule

// Parameterized NOR
module nor_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = ~(a | b);
endmodule

// Parameterized XOR
module xor_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = a ^ b;
endmodule

// Parameterized XNOR
module xnor_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] y
);
    assign y = ~(a ^ b);
endmodule

// Parameterized NOT
module not_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    output [WIDTH-1:0] y
);
    assign y = ~a;
endmodule

// Parameterized Shifter
module shifter_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [1:0] shift, 
    output [WIDTH-1:0] y
);
    assign y = (shift == 2'b00) ? a : 
               (shift == 2'b01) ? {a[WIDTH-2:0], 1'b0} :
               (shift == 2'b10) ? {1'b0, a[WIDTH-1:1]} : 
                                  {WIDTH{1'b0}}; // Undefined shift, outputs 0
endmodule

// Parameterized Addition
module add_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    input cin, 
    output [WIDTH-1:0] sum, 
    output cout
);
    assign {cout, sum} = a + b + cin;
endmodule

// Parameterized Subtraction
module sub_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    input cin, 
    output [WIDTH-1:0] diff, 
    output cout
);
    assign {cout, diff} = a - b - cin;
endmodule

// Parameterized Multiplication
module mul_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [(2*WIDTH)-1:0] product
);
    assign product = a * b;
endmodule

// Parameterized Division
module div_param #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b, 
    output [WIDTH-1:0] quotient, 
    output [WIDTH-1:0] remainder
);
    assign quotient = a / b;
    assign remainder = a % b;
endmodule

// Top-level ALU module
module alu #(parameter WIDTH = 4) (
    input [WIDTH-1:0] a, 
    input [WIDTH-1:0] b,
    input cin,
    input [1:0] shift,
    input [3:0] control,  // Control signal to select operation
    output reg [WIDTH-1:0] result,
    output reg cout,
    output reg [WIDTH-1:0] remainder, // Only for division
    output reg [(2*WIDTH)-1:0] product // Only for multiplication
);
    // Intermediate signals
    wire [WIDTH-1:0] y_and, y_nand, y_or, y_nor, y_xor, y_xnor, y_not, y_shift, sum, diff, quotient, temp_remainder;
    wire cout_add, cout_sub;
    wire [(2*WIDTH)-1:0] temp_product;

    // Instantiate all operation modules
    and_param #(WIDTH) u_and (.a(a), .b(b), .y(y_and));
    nand_param #(WIDTH) u_nand (.a(a), .b(b), .y(y_nand));
    or_param #(WIDTH) u_or (.a(a), .b(b), .y(y_or));
    nor_param #(WIDTH) u_nor (.a(a), .b(b), .y(y_nor));
    xor_param #(WIDTH) u_xor (.a(a), .b(b), .y(y_xor));
    xnor_param #(WIDTH) u_xnor (.a(a), .b(b), .y(y_xnor));
    not_param #(WIDTH) u_not (.a(a), .y(y_not));
    shifter_param #(WIDTH) u_shifter (.a(a), .shift(shift), .y(y_shift));
    add_param #(WIDTH) u_add (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout_add));
    sub_param #(WIDTH) u_sub (.a(a), .b(b), .cin(cin), .diff(diff), .cout(cout_sub));
    mul_param #(WIDTH) u_mul (.a(a), .b(b), .product(temp_product));
    div_param #(WIDTH) u_div (.a(a), .b(b), .quotient(quotient), .remainder(temp_remainder));

    // Control circuit to select the operation
    always @(*) begin
        case (control)
            4'b0000: begin result = y_and; cout = 0; end      // AND
            4'b0001: begin result = y_nand; cout = 0; end     // NAND
            4'b0010: begin result = y_or; cout = 0; end       // OR
            4'b0011: begin result = y_nor; cout = 0; end      // NOR
            4'b0100: begin result = y_xor; cout = 0; end      // XOR
            4'b0101: begin result = y_xnor; cout = 0; end     // XNOR
            4'b0110: begin result = y_not; cout = 0; end      // NOT
            4'b0111: begin result = y_shift; cout = 0; end    // Shifter
            4'b1000: begin result = sum; cout = cout_add; end // Addition
            4'b1001: begin result = diff; cout = cout_sub; end // Subtraction
            4'b1010: begin product = temp_product; cout = 0; end   // Multiplication
            4'b1011: begin result = quotient; cout = 0; remainder = temp_remainder; end // Division
            default: begin result = {WIDTH{1'b0}}; cout = 0; end
        endcase
    end
endmodule

// Testbench
module testbench;
    // Inputs
    reg [31:0] a, b;
    reg cin;
    reg [1:0] shift;
    reg [3:0] control;

    // Outputs
    wire [31:0] result;
    wire cout;
    wire [31:0] remainder;
    wire [63:0] product;

    // Instantiate the Unit Under Test (UUT)
    alu #(32) uut (
        .a(a), 
        .b(b), 
        .cin(cin), 
        .shift(shift), 
        .control(control), 
        .result(result), 
        .cout(cout),
        .remainder(remainder),
        .product(product)
    );

    initial begin
        // Initialize Inputs
        $dumpfile("finalStep.vcd");
        $dumpvars(0, testbench);

        // Test 4-bit ALU
        a = 4'b0001; b = 4'b0010; cin = 1'b0; shift = 2'b00;

        // Test each operation
        control = 4'b0000; // AND
        #10; $display("4-bit Test - AND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0001; // NAND
        #10; $display("4-bit Test - NAND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0010; // OR
        #10; $display("4-bit Test - OR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0011; // NOR
        #10; $display("4-bit Test - NOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0100; // XOR
        #10; $display("4-bit Test - XOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0101; // XNOR
        #10; $display("4-bit Test - XNOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0110; // NOT
        #10; $display("4-bit Test - NOT: a = %b, result = %b", a, result);

        shift = 2'b01; control = 4'b0111; // Shifter
        #10; $display("4-bit Test - Shifter: a = %b, shift = %b, result = %b", a, shift, result);

        cin = 1'b1; control = 4'b1000; // Addition
        #10; $display("4-bit Test - Addition: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1001; // Subtraction
        #10; $display("4-bit Test - Subtraction: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1010; // Multiplication
        #10; $display("4-bit Test - Multiplication: a = %b, b = %b, product = %b", a, b, product);

        control = 4'b1011; // Division
        #10; $display("4-bit Test - Division: a = %b, b = %b, quotient = %b, remainder = %b", a, b, result, remainder);

        // Test 8-bit ALU
        a = 8'h01; b = 8'h02; control = 4'b0000; // AND
        #10; $display("8-bit Test - AND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0001; // NAND
        #10; $display("8-bit Test - NAND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0010; // OR
        #10; $display("8-bit Test - OR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0011; // NOR
        #10; $display("8-bit Test - NOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0100; // XOR
        #10; $display("8-bit Test - XOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0101; // XNOR
        #10; $display("8-bit Test - XNOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0110; // NOT
        #10; $display("8-bit Test - NOT: a = %b, result = %b", a, result);

        shift = 2'b01; control = 4'b0111; // Shifter
        #10; $display("8-bit Test - Shifter: a = %b, shift = %b, result = %b", a, shift, result);

        cin = 1'b1; control = 4'b1000; // Addition
        #10; $display("8-bit Test - Addition: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1001; // Subtraction
        #10; $display("8-bit Test - Subtraction: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1010; // Multiplication
        #10; $display("8-bit Test - Multiplication: a = %b, b = %b, product = %b", a, b, product);

        control = 4'b1011; // Division
        #10; $display("8-bit Test - Division: a = %b, b = %b, quotient = %b, remainder = %b", a, b, result, remainder);

        // Test 16-bit ALU
        a = 16'h0001; b = 16'h0002; control = 4'b0000; // AND
        #10; $display("16-bit Test - AND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0001; // NAND
        #10; $display("16-bit Test - NAND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0010; // OR
        #10; $display("16-bit Test - OR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0011; // NOR
        #10; $display("16-bit Test - NOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0100; // XOR
        #10; $display("16-bit Test - XOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0101; // XNOR
        #10; $display("16-bit Test - XNOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0110; // NOT
        #10; $display("16-bit Test - NOT: a = %b, result = %b", a, result);

        shift = 2'b01; control = 4'b0111; // Shifter
        #10; $display("16-bit Test - Shifter: a = %b, shift = %b, result = %b", a, shift, result);

        cin = 1'b1; control = 4'b1000; // Addition
        #10; $display("16-bit Test - Addition: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1001; // Subtraction
        #10; $display("16-bit Test - Subtraction: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1010; // Multiplication
        #10; $display("16-bit Test - Multiplication: a = %b, b = %b, product = %b", a, b, product);

        control = 4'b1011; // Division
        #10; $display("16-bit Test - Division: a = %b, b = %b, quotient = %b, remainder = %b", a, b, result, remainder);

        // Test 32-bit ALU
        a = 32'h00000001; b = 32'h00000002; control = 4'b0000; // AND
        #10; $display("32-bit Test - AND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0001; // NAND
        #10; $display("32-bit Test - NAND: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0010; // OR
        #10; $display("32-bit Test - OR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0011; // NOR
        #10; $display("32-bit Test - NOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0100; // XOR
        #10; $display("32-bit Test - XOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0101; // XNOR
        #10; $display("32-bit Test - XNOR: a = %b, b = %b, result = %b", a, b, result);

        control = 4'b0110; // NOT
        #10; $display("32-bit Test - NOT: a = %b, result = %b", a, result);

        shift = 2'b01; control = 4'b0111; // Shifter
        #10; $display("32-bit Test - Shifter: a = %b, shift = %b, result = %b", a, shift, result);

        cin = 1'b1; control = 4'b1000; // Addition
        #10; $display("32-bit Test - Addition: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1001; // Subtraction
        #10; $display("32-bit Test - Subtraction: a = %b, b = %b, cin = %b, result = %b, cout = %b", a, b, cin, result, cout);

        control = 4'b1010; // Multiplication
        #10; $display("32-bit Test - Multiplication: a = %b, b = %b, product = %b", a, b, product);

        control = 4'b1011; // Division
        #10; $display("32-bit Test - Division: a = %b, b = %b, quotient = %b, remainder = %b", a, b, result, remainder);

        $finish;
    end
endmodule
