`ifndef ROW_WIDTH
    `define ROW_WIDTH 4
`endif

`ifndef WIDTH
    `define WIDTH 8
`endif

`ifndef HEIGHT
    `define HEIGHT 4
`endif

module sobel_filter(
    input clk, rst,
    input [`WIDTH-1:0] pixel,
    output reg [10:0] gradient, // max value 2040 min value 0 i.e. 11 bit
    output reg gradient_valid
);

    reg [`WIDTH-1:0] upper_row [0:`ROW_WIDTH-1];
    reg [`WIDTH-1:0] middle_row [0:`ROW_WIDTH-1];
    reg [`WIDTH-1:0] lower_row [0:`ROW_WIDTH-1];

    reg [5:0] col;
    reg [5:0] row;

    reg [5:0] sobel_col, sobel_col_delay;
    reg start, start_delay;

    reg signed [10:0] gx; // max value 1020 min value -1020 i.e. 10 bit + 1 bit for sign
    reg signed [10:0] gy;

    reg [`WIDTH-1:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;

    always@(posedge clk) begin
        if(rst) begin
            col <= 0;
            row <= 0;
            sobel_col <= 1;
            start <= 1'b0;
            gradient <= 0;
            gradient_valid <= 1'b0;
            start_delay      <= 1'b0;
            sobel_col_delay  <= 0;
        end
        else begin

            // stores the window data
            lower_row[col] <= pixel;
            middle_row[col] <= lower_row[col];
            upper_row[col] <= middle_row[col];

            // updates the col and rows 
            if(col == `ROW_WIDTH-1) begin
                col <= 0;
                row <= row + 1;
                start <= (row>=2);
                sobel_col <= 1;
            end
            else begin
                col <= col + 1;
            end

            // for gradient calculation
            if(start&&sobel_col<`ROW_WIDTH-2) begin
                p00 <= upper_row[sobel_col-1];
                p01 <= upper_row[sobel_col  ];
                p02 <= upper_row[sobel_col+1];
                p10 <= middle_row[sobel_col-1];
                p11 <= middle_row[sobel_col  ];
                p12 <= middle_row[sobel_col+1];
                p20 <= lower_row[sobel_col-1];
                p21 <= lower_row[sobel_col  ];
                p22 <= lower_row[sobel_col+1];
                sobel_col <= sobel_col + 1;
            end

            start_delay <= start;  // for clean gradient calculation
            sobel_col_delay  <= sobel_col;

            gradient_valid <= 1'b0;

        end
    end

    // calculation of the gradient

    always@(posedge clk) begin
        if(rst) begin
            gradient <= 0;
            gradient_valid <= 1'b0;
        end
      else if((start_delay)&&(sobel_col_delay<`ROW_WIDTH-2)) begin
            gx = -p00 - 2*p10 - p20 + (p02 + 2*p12 + p22);  
            gy = -p00 - 2*p01 - p02 + (p20 + 2*p21 + p22);

            gradient <= (gx[10] ? -gx : gx) + (gy[10] ? -gy : gy); // cheap mathod |Gx|+|Gy| real is sqrt(Gx^2 + Gy^2)
            gradient_valid <= 1'b1;
        end
    end

endmodule