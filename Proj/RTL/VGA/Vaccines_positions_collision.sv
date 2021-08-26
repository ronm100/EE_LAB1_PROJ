module	Vaccines_positions_collision	(	
 
					input	logic	clk,
					input	logic	resetN,
					//input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					//input	logic	launch_Cable,  //change the direction in Y to up  
					//input	logic	toggleX, 	//toggle the X direction 
					input logic collision,
					input logic [0:3] collision_clamp_vaccine,  //collision if smiley hits an object
					//input	logic	[3:0] HitEdgeCode, //one bit per edge 
					//input logic [10:0] pixelX,
					//input logic [10:0] pixelY,
					input logic [10:0] randX,
					input logic [10:0] randY,
					input logic [0:9] rand_draw_request,
					input logic IsInCircularMovement,

					output	 logic signed 	[0:9][10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[0:9][10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output logic [0:9] Draw_request //1- the object should be drawn, 0 the object should not be drawn
);


// a module used to generate the  ball trajectory.  

logic signed [0:9] [10:0] INITIAL_X = {11'd70,11'd80,11'd140,11'd200,11'd170,11'd330,11'd370,11'd480,11'd440,11'd550}; // TODO: MAKE THIS LOCAL PARAM
logic signed [0:9] [10:0] INITIAL_Y = {11'd200,11'd320,11'd160,11'd200,11'd410,11'd330,11'd170,11'd380,11'd180,11'd180}; // TODO: MAKE THIS LOCAL PARAM
//parameter int INITIAL_X_SPEED = 0; // TODO: MAKE THIS LOCAL PARAM
//parameter int INITIAL_Y_SPEED = 0; // TODO: MAKE THIS LOCAL PARAM
//parameter int MAX_Y_SPEED = 230; // TODO: DELETE
//parameter int X_SPEED = 20; // TODO: DELETE
//parameter int Y_SPEED = 20; // TODO: DELETE
//localparam int CIRCULAR = 0;
//localparam int STRAIGHT = 1;
//localparam int RIGHT = 0;
//localparam int LEFT = 1;
//localparam real SPEED_CONST = 1/8;
//const int  Y_ACCEL = -1;
//logic movement_type; // 0 for circular movement, 1 for straight movement.
//logic circular_direction; // 0 for right, 1 for left.
logic [3:0] position_number = 0;
logic [0:9] [10:0] X_positions = {11'd70,11'd80,11'd140,11'd200,11'd170,11'd330,11'd370,11'd480,11'd440,11'd550};
logic [0:9] [10:0] Y_positions = {11'd200,11'd320,11'd160,11'd200,11'd410,11'd330,11'd170,11'd380,11'd180,11'd180};
logic [0:9] draw_request = 10'h3da;
logic [3:0] rand_index = 0;
logic [0:9] [10:0] X_rand_positions = {11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0};
logic [0:9] [10:0] Y_rand_positions = {11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0};


//logic[5:0] frame_counter;
//logic [3:0] circular_ps;
//logic [3:0] circular_ns;
//logic isInStartingLocation;

const int	FIXED_POINT_MULTIPLIER	=	1;
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

//assign isInStartingLocation = (topLeftX == (initial_positions[circular_ps][0] + INITIAL_X)) && (topLeftY == (initial_positions[circular_ps][1] + INITIAL_Y));

always_ff@(posedge clk or negedge resetN)
begin
	X_positions<=X_positions; 
	Y_positions<=Y_positions;
	draw_request<= draw_request;
	
	
	if(!resetN) begin 
		X_positions<=INITIAL_X;
		Y_positions<=INITIAL_Y;
		draw_request<= 10'h3da;
		
		//movement_type <= CIRCULAR;
		//circular_direction <= RIGHT;
		//circular_ps <= 0;
		//circular_ns <= 1;
		//frame_counter <= 0;
		
	end 
	else begin
	// colision Calcultaion 
			
		//hit bit map has one bit per edge:  Left-Top-Right-Bottom	 

		if ((!draw_request) && (IsInCircularMovement)) begin
			X_positions <= X_rand_positions;
			Y_positions <= Y_rand_positions;
			draw_request <= rand_draw_request;
//			position_number <= position_number + 1;
//			if (position_number == 10) begin
//				position_number <= 0;
//				
//			end
		end
		if (collision) begin
			draw_request[collision_clamp_vaccine] <= 0;
			X_rand_positions[rand_index] <= randX;
			Y_rand_positions[9-rand_index] <= randY;
			rand_index <= ((rand_index + 1) % 10);
			
		end
//		if(isInStartingLocation) begin //Cable should stop upon reaching initial spot 
//			if(Yspeed < 0) //Cable is in proccess of returning
//			begin
//				Yspeed <= 0 ; 
//				Xspeed <= 0 ;
//				movement_type <= CIRCULAR;
//			end
//			if(launch_Cable)
//			begin
//				Yspeed <= initial_speeds[circular_ps][1] / 8; 
//				Xspeed <= initial_speeds[circular_ps][0] / 8; 
//				movement_type <= STRAIGHT;
//			end
//		end
		
//		if ((collision)) begin //Collision should make the cable return
//			Yspeed <= -Yspeed ; 
//			Xspeed <= -Xspeed ; 
//		end
//		
//		if(movement_type == CIRCULAR)
//		begin
//			if(circular_direction == RIGHT)
//			begin
//				if(circular_ps == 6)
//					begin
//						circular_ns <= 5;
//						circular_direction <= LEFT;
//					end
//					else circular_ns <= circular_ps + 1;
//			end
//			
//			if(circular_direction == LEFT)
//			begin
//				if(circular_ps == 0)
//					begin
//						circular_ns <= 1;
//						circular_direction <= RIGHT;
//					end
//					else circular_ns <= circular_ps - 1;
//			end
//		end

		// perform  position and speed integral only 30 times per second 
		
//		if (startOfFrame == 1'b1) begin 
//				frame_counter <= (frame_counter +1) % 48;
//				if( frame_counter == 0 && movement_type == CIRCULAR) circular_ps <= circular_ns;
//				
//				if(movement_type == STRAIGHT)
//				begin
//					topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 
//					topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 
//				end
//				
//				else if(movement_type == CIRCULAR)
//				begin
//					topLeftY_FixedPoint  <= initial_positions[circular_ps][1] + INITIAL_Y; // position interpolation 
//					topLeftX_FixedPoint  <= initial_positions[circular_ps][0] + INITIAL_X; // position interpolation 
//				end
//		end
	end
end 

//get a better (64 times) resolution using integer   
assign 	topLeftX = X_positions ;   // note it must be 2^n 
assign 	topLeftY = Y_positions ; 
assign Draw_request = draw_request;  


endmodule