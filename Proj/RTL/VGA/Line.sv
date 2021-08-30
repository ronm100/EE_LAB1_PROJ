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
					input	logic signed	[10:0]	clamp_topLeftY, //the top left corner of the clamp
					input logic [5:0] circular_ps,
					
					
					output logic line_DR, // a request to draw a line on current pixelput l
					
					//DEBUG
					output logic DEBUG2,
					output logic DEBUG3,
					output logic signed [40:0] DEBUG

					
);


// a module used to generate the  ball trajectory.  

localparam logic signed [10:0] INITIAL_X = 288; // TODO: MAKE THIS LOCAL PARAM
localparam logic signed [10:0] INITIAL_Y = 64; // TODO: MAKE THIS LOCAL PARAM
localparam int MAX_STATE = 50;
localparam int ORTHAGONAL_STATE = 25;
localparam logic signed [6:0] DELTA = 7'd32;
localparam logic signed [6:0] DELTAN = -7'd32;
logic signed [MAX_STATE:0] [40:0] slopes_32 = { //The Slope between initial position and current position, multiplied by 32
41'd6, 41'd7, 41'd9, 41'd12, 41'd13, 41'd15, 41'd18, 41'd20, 41'd23, 41'd26, 41'd28, 41'd32, 41'd37, 41'd40, 41'd46, 41'd51, 41'd60, 41'd66, 41'd80, 41'd87, 41'd110, 41'd142, 41'd205, 41'd256, 41'd512, 41'd0, -41'd512, -41'd256, -41'd205, -41'd142, -41'd110, -41'd96, -41'd80, -41'd66, -41'd60, -41'd51, -41'd46, -41'd40, -41'd37, -41'd32, -41'd28, -41'd26, -41'd23, -41'd20, -41'd18, -41'd15, -41'd13, -41'd12, -41'd9, -41'd7, -41'd6
};
logic signed [MAX_STATE:0] [40:0] offsets_32= { //The Offset of the line between initial position and current position, multiplied by 32
41'd320, 41'd32, -41'd544, -41'd1408, -41'd1696, -41'd2272, -41'd3136, -41'd3712, -41'd4576, -41'd5440, -41'd6016, -41'd7168, -41'd8608, -41'd9472, -41'd11200, -41'd12640, -41'd15232, -41'd16960, -41'd20992, -41'd23008, -41'd29632, -41'd38848, -41'd56992, -41'd71680, -41'd145408, 41'd0, 41'd149504, 41'd75776, 41'd61088, 41'd42944, 41'd33728, 41'd29696, 41'd25088, 41'd21056, 41'd19328, 41'd16736, 41'd15296, 41'd13568, 41'd12704, 41'd11264, 41'd10112, 41'd9536, 41'd8672, 41'd7808, 41'd7232, 41'd6368, 41'd5792, 41'd5504, 41'd4640, 41'd4064, 41'd3776
};
logic isAboveClamp, isBelowCenter, isOnLine, conditionMax, conditionMin;

logic signed [40:0] bigX, bigY;  

always_comb
begin
	bigX = pixelX - INITIAL_X;
	bigY = (pixelY-INITIAL_Y) * DELTA;
	conditionMax = (bigY - ((bigX * slopes_32[circular_ps]))) > (DELTAN);
	conditionMin = (bigY - (bigX * slopes_32[circular_ps])) < (DELTA);
// Here we check if the current pixel is close enough to making both sides of the line equation equal.
	if(circular_ps == ORTHAGONAL_STATE) // Infinite slope
	begin
		if(pixelX == (INITIAL_X)) isOnLine = 1;
		else isOnLine = 0;
	end
	/*
	else if(((bigY - ((bigX * slopes_32[circular_ps]) - offsets_32[circular_ps])) < DELTA) && ((bigY- ((bigX * slopes_32[circular_ps]) - offsets_32[circular_ps])) > -DELTA))  //
		isOnLine = 1;
	*/
	else if(conditionMax && conditionMin)  //
		isOnLine = 1;
		
	else isOnLine = 0;
	
	//Here we check if the current pixel is above the clamp.
	if(pixelY < clamp_topLeftY) isAboveClamp = 1;
	else isAboveClamp = 0;
	
	//Here we check if current pixel is below the center of the circle of circular movement
	if(pixelY > INITIAL_Y) isBelowCenter = 1;
	else isBelowCenter = 0;
	
	//DEBUG
	DEBUG = (bigY - ((bigX * slopes_32[circular_ps])));
	DEBUG2 = ((bigY - (bigX * slopes_32[circular_ps])) < DELTA);
	DEBUG3 = ((bigY - ((bigX * slopes_32[circular_ps]))) > DELTAN);
end

always_ff@(posedge clk or negedge resetN)
begin
	
	line_DR <= isAboveClamp && isOnLine && isBelowCenter;
	//line_DR <= 0;
	
end 

endmodule
