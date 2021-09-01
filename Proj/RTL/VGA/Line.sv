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
					
					
					output logic line_DR // a request to draw a line on current pixelput l

					
);


// a module used to generate the  ball trajectory.  

localparam logic signed [10:0] INITIAL_X = 288;
localparam logic signed [10:0] INITIAL_Y = 64; 
localparam int MAX_STATE = 50;
localparam int ORTHAGONAL_STATE = 25;
localparam logic signed [40:0] DELTA = 32;

logic signed [MAX_STATE:0] [40:0] slopes_32 = { //The Slope between initial position and current position, multiplied by 32
41'd6, 41'd7, 41'd9, 41'd12, 41'd13, 41'd15, 41'd18, 41'd20, 41'd23, 41'd26, 41'd28, 41'd32, 41'd37, 41'd40, 41'd46, 41'd51, 41'd60, 41'd66, 41'd80, 41'd87, 41'd110, 41'd142, 41'd205, 41'd256, 41'd512, 41'd0, -41'd512, -41'd256, -41'd205, -41'd142, -41'd110, -41'd96, -41'd80, -41'd66, -41'd60, -41'd51, -41'd46, -41'd40, -41'd37, -41'd32, -41'd28, -41'd26, -41'd23, -41'd20, -41'd18, -41'd15, -41'd13, -41'd12, -41'd9, -41'd7, -41'd6
};

logic isAboveClamp, isBelowCenter, isOnLine;

logic signed [40:0] bigX, bigY, lineExpressionAbsVal, lineExpression;  

always_comb
begin
	bigX = pixelX - INITIAL_X;
	bigY = (pixelY-INITIAL_Y) * 32;
	lineExpression = (bigY - ((bigX * slopes_32[circular_ps])));
	lineExpressionAbsVal  = lineExpression[40] ? -lineExpression : lineExpression;
// Here we check if the current pixel is close enough to making both sides of the line equation equal.
	if((circular_ps > 13) && (circular_ps < 37) && (circular_ps != ORTHAGONAL_STATE))
	begin
		if(lineExpressionAbsVal < (2 * DELTA)) isOnLine = 1;
		else isOnLine = 0;
	end
	
	else if(circular_ps == ORTHAGONAL_STATE) // Infinite slope
	begin
		if(pixelX == (INITIAL_X)) isOnLine = 1;
		else isOnLine = 0;
	end
	
	else
	begin
		if(lineExpressionAbsVal < DELTA) isOnLine = 1;
		else isOnLine = 0;
	end
	
	//Here we check if the current pixel is above the clamp.
	if(pixelY < clamp_topLeftY) isAboveClamp = 1;
	else isAboveClamp = 0;
	
	//Here we check if current pixel is below the center of the circle of circular movement
	if(pixelY > INITIAL_Y) isBelowCenter = 1;
	else isBelowCenter = 0;
end

always_ff@(posedge clk or negedge resetN)
begin
	
	line_DR <= isAboveClamp && isOnLine && isBelowCenter;
	
end 

endmodule
