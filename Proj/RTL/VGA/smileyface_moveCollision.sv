// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	smileyface_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	launch_Cable,  //change the direction in Y to up  
					//input	logic	toggleX, 	//toggle the X direction 
					input logic collision,  //collision if smiley hits an object
					//input	logic	[3:0] HitEdgeCode, //one bit per edge 

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_Y_SPEED = 20;
parameter int MAX_Y_SPEED = 230;
parameter int X_SPEED = 20;
parameter int Y_SPEED = 20;
//const int  Y_ACCEL = -1;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	Yspeed <= Yspeed ; 
	Xspeed <= Xspeed ; 
	
	if(!resetN) begin 
		Yspeed	<= INITIAL_Y_SPEED;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
	end 
	else begin
	// colision Calcultaion 
			
		//hit bit map has one bit per edge:  Left-Top-Right-Bottom	 

		if((topLeftX == INITIAL_X) && (topLeftY == INITIAL_Y)) begin //Cable should stop upon reaching initial spot 
			if(Yspeed < 0)
			begin
				Yspeed <= 0 ; 
				Xspeed <= 0 ;
			end
			if(launch_Cable)
			begin
				Yspeed <= Y_SPEED ; 
				Xspeed <= X_SPEED ; 
			end
		end
		
		if ((collision)) begin //Collision should make the cable return
			Yspeed <= -Yspeed ; 
			Xspeed <= -Xspeed ; 
		end

		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) begin 
		
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 

		end
	end
end 

/*
//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
	end
	else begin
	
				
	//  an edge input is tested here as it is a very short instance   
	if (toggleX)  
	
				Xspeed <= -Xspeed; 
				
	// collisions with the sides 			
				if (collision && HitEdgeCode [3] == 1) begin  
					if (Xspeed < 0 ) // while moving left
							Xspeed <= -Xspeed ; // positive move right 
				end
			
				if (collision && HitEdgeCode [1] == 1 ) begin  // hit right border of brick  
					if (Xspeed > 0 ) //  while moving right
							Xspeed <= -Xspeed  ;  // negative move left    
				end	
		   
			
		if (startOfFrame == 1'b1 )//&& Yspeed != 0) 
	
				        topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
			
					
	end
end

*/
//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
