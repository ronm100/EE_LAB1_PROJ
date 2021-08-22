// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	Line	(	
 
					input	logic	clk,
					input	logic	resetN,
					
					input logic signed	[10:0] pixelX,// current VGA pixel 
					input logic signed	[10:0] pixelY,
					
					input	logic signed 	[10:0]	clamp_topLeftX, // the top left corner of the clamp
					input	logic signed	[10:0]	clamp_topLeftY, // can be negative , if the object is partliy outside 
					input logic [3:0] circular_ps,
					
					
					output logic line_DR // a request to draw a line on current pixel

					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 288; // TODO: MAKE THIS LOCAL PARAM    HAS TO BE THE SAME AS CLAMP'S
parameter int INITIAL_Y = 64; // TODO: MAKE THIS LOCAL PARAM    HAS TO BE THE SAME AS CLAMP'S
logic [0:3] [0:1] [6:0] initial_positions = {
{7'd5, 7'd66},{7'd16, 7'd84},{7'd32, 7'd94},{7'd48, 7'd96},{7'd67, 7'd94},{7'd84, 7'd82},{7'd94, 7'd66}
};
logic [0:3] [0:1] [6:0] si = {
{-7'd51, 7'd21},{-7'd40, 7'd40},{-7'd21, 7'd51},{7'd0, 7'd56},{7'd21, 7'd51},{7'd40, 7'd40},{7'd51, 7'd21}
};
logic[5:0] frame_counter;
logic isAboveClamp;
logic isOnLine;

const int	FIXED_POINT_MULTIPLIER	=	1;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportion


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision
always_comb
begin

	if(pixelY < clamp_topLeftY) isAboveClamp = 1;
	else isAboveClamp = 0;
	
	if( ((pixelY - INITIAL_Y) / (pixelX - INITIAL_X)) == ((pixelY - initial_positions[circular_ps][1]) / (pixelX - initial_positions[circular_ps][0])))
		isOnLine = 1;
	else isOnLine = 0;

end

always_ff@(posedge clk or negedge resetN)
begin
	
	line_DR <= isAboveClamp && isOnLine;
	
end 

endmodule
