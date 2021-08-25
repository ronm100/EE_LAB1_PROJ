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
					//output logic [3:0] circularState
);


// a module used to generate the  ball trajectory.  

parameter logic signed [10:0] INITIAL_X = 288; // TODO: MAKE THIS LOCAL PARAM
parameter logic signed [10:0] INITIAL_Y = 64; // TODO: MAKE THIS LOCAL PARAM
parameter int INITIAL_X_SPEED = 0; // TODO: MAKE THIS LOCAL PARAM
parameter int INITIAL_Y_SPEED = 0; // TODO: MAKE THIS LOCAL PARAM
parameter int MAX_Y_SPEED = 230; // TODO: DELETE
parameter int X_SPEED = 20; // TODO: DELETE
parameter int Y_SPEED = 20; // TODO: DELETE
localparam int CIRCULAR = 0;
localparam int STRAIGHT = 1;
localparam int RIGHT = 0;
localparam int LEFT = 1;
logic movement_type; // 0 for circular movement, 1 for straight movement.
logic circular_direction; // 0 for right, 1 for left.
logic signed [6:0] [0:1] [10:0] initial_positions = {
{-11'd30, 11'd2},{-11'd20, 11'd5},{-11'd10, 11'd10},{11'd0, 11'd15},{11'd10, 11'd10},{11'd20, 11'd5},{11'd30, 11'd2}
};
logic signed [6:0] [0:1] [10:0] initial_speeds = {
{-11'd8, 11'd1},{-11'd10, 11'd2},{-11'd10, 11'd10},{11'd0, 11'd15},{11'd10, 11'd10},{11'd10, 11'd2},{11'd15, 11'd1}
};


logic[5:0] frame_counter;
logic [3:0] circular_ps;
logic [3:0] circular_ns;
logic isInStartingLocation;
logic collisionFlag;// 1 if collision happend, 0 else

const int	FIXED_POINT_MULTIPLIER	=	1;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;
 
logic signed [10:0] topLeftX_FixedPoint, topLeftY_FixedPoint;
logic signed [10:0] Xspeed, Yspeed ;
logic signed [10:0] InitPosX ;
assign InitPosX = initial_positions[circular_ps][0];


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

assign isInStartingLocation = (topLeftX == (initial_positions[circular_ps][0] + INITIAL_X)) && (topLeftY == (initial_positions[circular_ps][1] + INITIAL_Y));

assign isInX = (topLeftX == (initial_positions[circular_ps][0] + INITIAL_X));
assign XINIT_POS = initial_positions[circular_ps][0];

always_ff@(posedge clk or negedge resetN)
begin
	Yspeed <= Yspeed ; 
	Xspeed <= Xspeed ; 
	
	
	if(!resetN) begin 
		Yspeed	<= INITIAL_Y_SPEED;
		topLeftY_FixedPoint	<= (initial_positions[0][1] + INITIAL_Y) * FIXED_POINT_MULTIPLIER;
		Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= (initial_positions[0][0] + INITIAL_X) * FIXED_POINT_MULTIPLIER;
		movement_type <= CIRCULAR;
		circular_direction <= RIGHT;
		circular_ps <= 0;
		circular_ns <= 1;
		frame_counter <= 0;
		collisionFlag <= 0;
		
	end 
	else begin
	// colision Calcultaion 
			
		//hit bit map has one bit per edge:  Left-Top-Right-Bottom	 

		if(isInStartingLocation) begin //Cable should stop upon reaching initial spot 
			if(Yspeed < 0) //Cable is in proccess of returning
			begin
				Yspeed <= 0 ; 
				Xspeed <= 0 ;
				movement_type <= CIRCULAR;
				collisionFlag <= 0;
			end
			if(launch_Cable)
			begin
				Yspeed <= initial_speeds[circular_ps][1]; 
				Xspeed <= initial_speeds[circular_ps][0]; 
				movement_type <= STRAIGHT;
			end
		end
		
		if ((collision && (!collisionFlag))) begin //Collision should make the cable return
			Yspeed <= -Yspeed ; 
			Xspeed <= -Xspeed ; 
			collisionFlag <= 1;
		end
		
		if(movement_type == CIRCULAR)
		begin
			if(circular_direction == RIGHT)
			begin
				if(circular_ps == 6)
					begin
						circular_ns <= 5;
						circular_direction <= LEFT;
					end
					else circular_ns <= circular_ps + 1;
			end
			
			if(circular_direction == LEFT)
			begin
				if(circular_ps == 0)
					begin
						circular_ns <= 1;
						circular_direction <= RIGHT;
					end
					else circular_ns <= circular_ps - 1;
			end
		end

		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) begin 
				frame_counter <= (frame_counter +1) % 48;
				if( frame_counter == 0 && movement_type == CIRCULAR) circular_ps <= circular_ns;
				
				if(movement_type == STRAIGHT)
				begin
					topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 
					topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 
				end
				
				else if(movement_type == CIRCULAR)
				begin
					topLeftY_FixedPoint  <= initial_positions[circular_ps][1] + INITIAL_Y; // position interpolation 
					topLeftX_FixedPoint  <= initial_positions[circular_ps][0] + INITIAL_X; // position interpolation 
				end
		end
	end
end 

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
