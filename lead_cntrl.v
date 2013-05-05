`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:27:52 09/19/2012 
// Design Name: 
// Module Name:    lead_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
/*
The purpose of this lead control is to control the flow of data from the RXD reciever and
deliver it to the UART_buffer to be saved.

It does this task by listening to the start and stop bytes from the RXD buffer and counting
the number of rising edges of the RXD's valid signal.
It listens for the right time to take a snap shot of the rxd buffer and then proceds to saving it
to the uart_buffer.

--The circular queue(aka uart_buffer): head is lead and tail is follow.
It offers the value Lead_o and Lead_next_o to tell the outside world  where it is pointing to the buffer.
It is pointing to an address in the buffer.  Lead_o is the address that it WILL write to and lead_next_o
is the address that it will go to next.  The follow_i is the way the outside world notifies this module
of the tail's address.

if the circular queue is not full, then it will continue to write at the head and move to the next available spot.
if it is full it will not write.  Trying to write may cause some data to be lost.  It will be like over filling a cup 
and watching the liquid over flow over the top.  It knows that it is full if the lead_next value is equal to the follow
value.

ie.
[F,L][LN][][] --initial position
[F][L][LN][] -- lead plants data at index 0
[F][][L][LN] -- plant at index 1
[LN,F][][][L] --plant at index 2 and its considered full
[LN][F][][L] -- follow consumes item at index 0 and moves to the next.  It does this until follow is the same index as Lead.

*/
//////
module lead_control(
    input clock,
    input [63:0] rxd_data_i,
    input valid_i,
	 input [6:0] follow_i,
    output [6:0] lead_o, lead_next_o,
    output reg data_we_o,
	 output reg [2:0] mode_num_o,
    output [10:0] write_addr_o, //Write_addr and Write_data are split here, but only for the purposes of being explicit about what is what.  When it is saved on to the buffer,  they will be concatenated.  The concatenated result will be the data and the value of lead_o will be the addr on the buffer.
    output [31:0] write_data_o
    );
wire buff_full_w; 
reg next_data_we_o;
/*reg*/wire ready2fire_w, next_ready2fire_w;
//reg [7:0] curr_mode_r, next_mode_r;
reg [6:0] curr_lead_r, next_lead_r; //maybe you need to creat current next paradigm.  It might be the case where this number is adding uncontrollably....
reg [6:0] curr_lead_next_r, next_lead_next_r;//currentnext paradigm....?
//reg [7:0] start_a;
//reg [7:0] stop_a;
///*Set stop_a a slice of the large word*/
`define STOP_A rxd_data_i[ 63: 56 ]
/*data and addr values out to mem*/
assign write_addr_o = rxd_data_i[ 50: 40];
assign write_data_o = rxd_data_i[39 :8];
///*Set start_a a slice of the large word*/
`define START_A rxd_data_i[ 7: 0 ]
`define FALSE 1'b0
`define TRUE 1'b1

//helper functions;
/* if buff is full value is 1 otherwise 0 */
assign buff_full_w = (curr_lead_next_r == follow_i)? `TRUE : `FALSE;
/* ready2fire is a flag that goes high when it appears to have finished sending a complete word of 64 bits */
assign ready2fire_w = (//curr_mode_r == 8'b0000_0001 &&
									mode_r == 3'b000 &&
									`START_A == 8'b0000_0000 &&
									`STOP_A == 8'b1111_1111 &&
									buff_full_w == `FALSE)? 
									`TRUE : 
									`FALSE ;
//always @ (curr_mode_r, `START_A, `STOP_A, buff_full_w) begin 
//	next_ready2fire_w <= (//curr_mode_r == 8'h01 && 
//									`START_A == 8'h00 &&
//									`STOP_A == 8'hFF &&
//									buff_full_w == `FALSE)? 
//									`TRUE : 
//									`FALSE ;
//end

/*make Internal variables available to the outside world*/
assign lead_o = curr_lead_r;
assign lead_next_o = curr_lead_next_r;

//lead_fsm
//-- list states
`define NUM_LEAD_STATES 4
`define init_lead 		`NUM_LEAD_STATES'b1000
`define	idle_lead 		`NUM_LEAD_STATES'b0100
`define	write_buff	`NUM_LEAD_STATES'b0010
`define	delay_lead		`NUM_LEAD_STATES'b0001
reg [(`NUM_LEAD_STATES-1):0] curr_sm_lead = `init_lead;
reg [(`NUM_LEAD_STATES-1):0] next_sm_lead = `init_lead;

//	always @ (posedge clock, ready2fire_w ) begin
//		curr_sm_lead <= next_sm_lead;
//	end
	always @ (curr_sm_lead, ready2fire_w,curr_lead_r, curr_lead_next_r, valid_i) begin
		case (curr_sm_lead)
			`init_lead : begin
				next_data_we_o <= 1'b0;
				next_lead_r <= { 7{ 1'b0 } };
				next_lead_next_r[6:1] <= { 6{1'b0} };
				next_lead_next_r[0] <= 1'b1;
				if(valid_i == 1'b1) begin
					next_sm_lead <= `idle_lead;
				end else begin
					next_sm_lead <= `init_lead;
				end
			end
			`idle_lead : begin
				next_data_we_o <= 1'b0;
				next_lead_r <= curr_lead_r;
				next_lead_next_r <= curr_lead_next_r;
				if (ready2fire_w == 1'b1 && valid_i == 1'b1) begin
					next_sm_lead <= `write_buff;
				end else begin
					next_sm_lead <= `idle_lead;
				end
			end
			`write_buff : begin
				next_data_we_o <= 1'b1;
				next_lead_r <= curr_lead_r;
				next_lead_next_r <= curr_lead_next_r;
				next_sm_lead <= `delay_lead;
			end
			`delay_lead : begin
				next_data_we_o <= 1'b0;
				if( ready2fire_w == 1'b0 || valid_i == 1'b0) begin
					next_lead_r <= curr_lead_r + 7'b0000001;
					next_lead_next_r <= curr_lead_next_r + 7'b0000001;
					next_sm_lead <= `idle_lead;
				end else begin
					next_lead_r <= curr_lead_r;
					next_lead_next_r <= curr_lead_next_r;
					next_sm_lead <= `delay_lead;
				end
			end
		endcase
	end
//---end lead_fsm

////mode_fsm
////-- list states
//`define NUM_MODE_STATES 3
//`define mode_init 			`NUM_MODE_STATES'b001
//`define	mode_not_valid 	`NUM_MODE_STATES'b010
//`define	mode_valid 		`NUM_MODE_STATES'b100
////-- list state variables
//reg [(`NUM_MODE_STATES-1):0] curr_sm_mode = `mode_init;
//reg [(`NUM_MODE_STATES-1):0] next_sm_mode = `mode_init;
////---fsm
////	always @ (posedge clock) begin
////		curr_sm_mode <= next_sm_mode;
////	end
//	always @ (curr_sm_mode, valid_i, curr_mode_r) begin
//		case ( curr_sm_mode ) 
//			`mode_init : begin 
//				next_mode_r <= 8'h01;
//				next_sm_mode <= `mode_not_valid;
//			end 
//			`mode_not_valid : begin
//				if (valid_i == 1'b1) begin
//					next_mode_r[7:0] <= {curr_mode_r[6:0] , curr_mode_r[7]};
//					next_sm_mode <= `mode_valid;
//				end else begin
//					next_sm_mode <= `mode_not_valid;
//				end
//			end
//			`mode_valid : begin
//				if (valid_i == 1'b0) begin
//					next_sm_mode <= `mode_not_valid;
//				end else begin
//					next_sm_mode <= `mode_valid;
//				end
//			end
//			default : begin next_sm_mode <= `mode_init; end
//		endcase
//	end
//---end mode_fsm
//---sync data
	always @ (posedge clock ) begin
			curr_sm_lead <= next_sm_lead;
//			curr_sm_mode <= next_sm_mode;
			curr_lead_r <= next_lead_r;
			curr_lead_next_r <= next_lead_next_r;
			mode_r <= next_mode_r;
			mode_num_o <= next_mode_r;
			data_we_o <= next_data_we_o;
	//		curr_mode_r <= next_mode_r;
			//ready2fire_w <= next_ready2fire_w;
	end
//---end sync data

//
//`define NUM_ST_MODE 9
//`define MODE_INIT `NUM_ST_MODE'b1_0000_0000
//`define MODE0 `NUM_ST_MODE'b0_1000_0000
//`define MODE1 `NUM_ST_MODE'b0_0100_0000
//`define MODE2 `NUM_ST_MODE'b0_0010_0000
//`define MODE3 `NUM_ST_MODE'b0_0001_0000
//`define MODE4 `NUM_ST_MODE'b0_0000_1000
//`define MODE5 `NUM_ST_MODE'b0_0000_0100
//`define MODE6 `NUM_ST_MODE'b0_0000_0010
//`define MODE7 `NUM_ST_MODE'b0_0000_0001
//reg [`NUM_ST_MODE-1:0] MODE_ST = `MODE_INIT;
reg [2:0] mode_st;
reg [2:0] mode_r;
reg [2:0] next_mode_r;
reg [19:0] mode_cnt;
`define MAX_MODE_CNT 20'b1111_1111_1111_1111_1111
//always @ (posedge clock ) begin
//	case(mode_st) 
//		3'b001: begin //initalize and hold for one second
//			if (mode_cnt == `MAX_MODE_CNT) begin
//				mode_st <= 3'b010;
//			end else begin	
//				mode_st <= 3'b001;//mode_st;
//				mode_cnt <= mode_cnt + 20'b0000_0000_0000_0000_0001;
//			end
//			
//		end
//		3'b010: begin //valid low
//			if (valid_i == 1'b1) begin 
//				mode_st <= 3'b100;
//				next_mode_r <= mode_r + 3'b001;
//			end else begin mode_st <= 3'b010; //mode_st;	
//			end;
//		end
//		3'b100: begin //valid high
//			if (valid_i == 1'b0) begin mode_st <= 3'b010;
//			end else begin mode_st <= 3'b100;//mode_st;	
//			end;
//		end
//		default: begin
//			mode_st <= 3'b001;
//			next_mode_r <= 3'b001;
//			mode_cnt <= 20'b0000_0000_0000_0000_0000;
//		end
//	endcase
//end
always @ (posedge valid_i) begin
	next_mode_r <= mode_r + 3'b001;
end
initial begin
	mode_cnt = 20'b0000_0000_0000_0000_0000;
	mode_st = 3'b001;
	mode_r = 3'b000;
	next_mode_r = 3'b000;
//	//MODE_ST = `MODE_INIT;
end
//always @ (posedge valid_i)
//begin
//	case(MODE_ST)
//		`MODE_INIT:begin
//			MODE_ST <= `MODE1;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE0:begin
//			MODE_ST <= `MODE1;
//			curr_mode_r <= 8'b0000_0001;
//		end
//		`MODE1:begin
//			MODE_ST <= `MODE2;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE2:begin
//			MODE_ST <= `MODE3;	
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE3:begin
//			MODE_ST <= `MODE4;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE4:begin
//			MODE_ST <= `MODE5;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE5:begin
//			MODE_ST <= `MODE6;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE6:begin
//			MODE_ST <= `MODE7;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		`MODE7:begin
//			MODE_ST <= `MODE0;
//			curr_mode_r <= 8'b0000_0000;
//		end
//		default:begin
//			MODE_ST <= `MODE_INIT;
//			curr_mode_r <= 8'b0000_0000;
//		end
//	endcase
//end
endmodule
