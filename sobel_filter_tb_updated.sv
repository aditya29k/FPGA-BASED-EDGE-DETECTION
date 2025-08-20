`ifndef ROW_WIDTH
    `define ROW_WIDTH 640
`endif

`ifndef WIDTH
    `define WIDTH 8
`endif

`ifndef HEIGHT
    `define HEIGHT 480
`endif

interface sobel_intf;
    logic clk, rst;
    logic [`WIDTH-1:0] pixel;
    logic [10:0] gradient;
    logic gradient_valid;
endinterface

module tb;
  
  sobel_intf intf();
  
  sobel_filter DUT(intf.clk, intf.rst, intf.pixel, intf.gradient, intf.gradient_valid);
  
  reg [`WIDTH-1:0] mem [0:`ROW_WIDTH*`HEIGHT-1];
  
  initial begin
    intf.clk <= 1'b0;
  end
  
  always #5 intf.clk <= ~intf.clk;
  
  integer i;
  integer count;
  localparam TOTAL_VALID = (`ROW_WIDTH-2)*(`HEIGHT-2);

  // SEND ALL BLACK

  task feed_black();
    for(i=0; i<`ROW_WIDTH*`HEIGHT; i++) begin
      intf.pixel <= mem[i];
      @(posedge intf.clk);
    end
  endtask
  
  task store_black();
    for(i=0; i<`ROW_WIDTH*`HEIGHT; i++) begin
      mem[i] = 0;
    end
  endtask
  
  // SEND ALL WHITE
  
  int file;

  task feed_white();
    for(i=0; i<`ROW_WIDTH*`HEIGHT; i++) begin
      intf.pixel <= mem[i];
      @(posedge intf.clk);
    end
  endtask
  
  task store_white();
    for(i=0; i<`ROW_WIDTH*`HEIGHT; i++) begin
      mem[i] = 255;
    end
  endtask

  // SEND MEM FILE

  integer file;

  reg [`WIDTH-1:0] mem_hex [0:`ROW_WIDTH*`HEIGHT - 1];

  task feed_mem_file();
    for(i=0; i<`ROW_WIDTH*`HEIGHT; i++) begin
        intf.pixel <= mem_hex[i];
        @(posedge intf.clk);
    end
  endtask
  
  task store_mem_file();
    $readmemh("donkey.mem", mem_hex);
  endtask
  
  initial begin
    intf.rst <= 1'b1;
    intf.pixel <= 0;
    count = 0;
    repeat(3) @(posedge intf.clk);
    $display("SYSTEM RESET");
    intf.rst <= 1'b0;
    
    store_black();
    feed_black();
    wait(count == TOTAL_VALID);
    
    intf.rst <= 1'b1;
    intf.pixel <= 0;
    count = 0;
    repeat(3) @(posedge intf.clk);
    $display("SYSTEM RESET");
    intf.rst <= 1'b0;
    
    store_white();
    feed_white();
    wait(count == TOTAL_VALID);
    
    intf.rst <= 1'b1;
    intf.pixel <= 0;
    count = 0;
    repeat(3) @(posedge intf.clk);
    $display("SYSTEM RESET");
    intf.rst <= 1'b0;
    
    store_mem_file();
    feed_mem_file();
    wait(count == TOTAL_VALID);
    $fclose(file);
    
    $finish();
  end

  initial begin
    file = $fopen("mem_recv.mem", "w");
    if(file == 0) begin
        $display("UNABLE TO CREATE FILE");
        $finish();
    end
  end
  
  always@(posedge intf.clk) begin
    if(intf.gradient_valid) begin
      $display("Gradient[%0d] = %0d", count, intf.gradient);
      $fdisplay(file, "%0h", mem_hex[count]);
      count++;
    end
  end
  
endmodule