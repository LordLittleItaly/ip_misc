// *******************************************************
// Date Created   : 28 February, 2020
// Author         : LLI
// *******************************************************

module ip_misc_fifo_async_top #( parameter FIFO_DEPTH = 16, DATA_WIDTH = 32 )( 

                                // Global Inputs
                                // +++++++++++++
                                wr_clk,
                                rd_clk,
                                rstn,

                                // Write Domain
                                // ++++++++++++
                                wr_en,
                                d_in,

                                fifo_full,

                                // Read Domain
                                // +++++++++++
                                rd_en,

                                d_out,
                                fifo_empty
);

    // Signal Declarations
    // +++++++++++++++++++
    input wire wr_clk;
    input wire rd_clk;
    input wire rstn;
    
    input wire wr_en;
    input wire [DATA_WIDTH-1:0] d_in;
    
    output reg fifo_full;
    
    input wire rd_en;
    
    output reg [DATA_WIDTH-1:0] d_out;
    output reg fifo_empty;

    // Internal Signals
    // ++++++++++++++++
    integer i;
    reg [$clog2(FIFO_DEPTH):0] wr_addr_count_n, wr_addr_count_r, rd_addr_count_n, rd_addr_count_r;

    // Memory Declaration
    // ++++++++++++++++++
    reg [DATA_WIDTH-1:0] mem_arr [2**$clog2(FIFO_DEPTH)];

    // FSM
    // +++
    always@( posedge wr_clk or negedge rstn )
    begin
        // Initialization Code
        // +++++++++++++++++++
        mem_arr <= mem_arr;

        if( !rstn )
        begin
            wr_addr_count_r <= 0;
            fifo_full <= 0;

            for( i = 0; i < 2**$clog2(FIFO_DEPTH); i++ )
            begin
                mem_arr[i] <= 0;
            end
        end
        else
        begin
            wr_addr_count_r <= wr_addr_count_n;
            if( wr_en && !fifo_full )
            begin
                mem_arr[wr_addr_count_r[$clog2(FIFO_DEPTH)-1:0]] <= d_in;
            end
            if( rd_en && !fifo_empty )
            begin
                d_out <= mem_arr[rd_addr_count_r[$clog2(FIFO_DEPTH)-1:0]];
            end

            if( ( wr_addr_count_r[$clog2(FIFO_DEPTH)] == ~rd_addr_count_r[$clog2(FIFO_DEPTH)] ) && ( wr_addr_count_r[$clog2(FIFO_DEPTH)-1:0] == rd_addr_count_r[$clog2(FIFO_DEPTH)-1:0] ) )
            begin
                fifo_full <= 1'b1;
            end
            else
            begin
                fifo_full <= 1'b0;
            end
        end
    end
    
    always@( posedge rd_clk or negedge rstn )
    begin

        if( !rstn )
        begin
            rd_addr_count_r <= 0;
            fifo_empty <= 1'b1;
        end
        else
        begin
            rd_addr_count_r <= rd_addr_count_n;
            
            if( ( wr_addr_count_r[$clog2(FIFO_DEPTH)] == rd_addr_count_r[$clog2(FIFO_DEPTH)] ) && ( wr_addr_count_r[$clog2(FIFO_DEPTH)-1:0] == rd_addr_count_r[$clog2(FIFO_DEPTH)-1:0] ) )
            begin
                fifo_empty <= 1'b1;
            end
            else
            begin
                fifo_empty <= 1'b0;
            end
        end
    end

    always@( * )
    begin
        rd_addr_count_n = wr_addr_count_r;
        wr_addr_count_n = wr_addr_count_r;

        if( wr_en )
        begin
            wr_addr_count_n = wr_addr_count_r + 1'b1;
        end
        
        if( rd_en )
        begin
            rd_addr_count_n = wr_addr_count_r + 1'b1;
        end
    end

endmodule
