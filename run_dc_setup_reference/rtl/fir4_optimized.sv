module fir4_optimized #(parameter w=16)(
    input                      clk,
                               reset,
    input         [w-1:0]      a,
    output logic  [w+1:0]      s);

    // delay pipeline for input a
    logic [w-1:0] ar, br, cr, dr;

    // Carry Lookahead Adder Logic
    logic [w-1:0] g, p; // generate and propagate
    logic [w:0]   carry; // carry array, extra bit for carry out

    // Generate and Propagate
    always_comb begin
        for(int i = 0; i < w; i++) begin
            g[i] = ar[i] & br[i]; // generate
            p[i] = ar[i] | br[i]; // propagate
        end
    end

    // Carry calculation
    assign carry[0] = 0; // no carry-in for the least significant bit
    always_comb begin
        for(int i = 0; i < w; i++) begin
            carry[i+1] = g[i] | (p[i] & carry[i]);
        end
    end

    // Sum calculation
    logic [w-1:0] sum;
    always_comb begin
        for(int i = 0; i < w; i++) begin
            sum[i] = ar[i] ^ br[i] ^ carry[i];
        end
    end

    // Sequential logic
    always_ff @(posedge clk) begin
        if(reset) begin
            ar <= '0;
            br <= '0;
            cr <= '0;
            dr <= '0;
            s  <= '0;
        end else begin
            ar <= a;
            br <= ar;
            cr <= br;
            dr <= cr;
            s  <= {carry[w], sum}; // the final sum, including carry out
        end
    end
endmodule

