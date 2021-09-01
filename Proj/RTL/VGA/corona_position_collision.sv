module	corona_positions_collision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input logic collision,
					input logic [0:3] collision_clamp_corona,  //collision if clamp hits an object
					input logic [10:0] randX,
					input logic [10:0] randY,
					input logic [0:9] rand_draw_request,
					input logic IsInCircularMovement,
					input logic EndOfPhase1, //start to add objects

					output	 logic signed 	[0:9][10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[0:9][10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output logic [0:9] Draw_request //1- the object should be drawn, 0 the object should not be drawn
);

//initial locations

localparam logic signed [0:9] [10:0] INITIAL_X = {11'd70,11'd80,11'd140,11'd200,11'd170,11'd330,11'd370,11'd480,11'd440,11'd550};
localparam logic signed [0:9] [10:0] INITIAL_Y = {11'd200,11'd320,11'd160,11'd200,11'd410,11'd330,11'd170,11'd380,11'd180,11'd180};

//temporary locations
logic [0:9] [10:0] X_positions = {11'd70,11'd80,11'd140,11'd200,11'd170,11'd330,11'd370,11'd480,11'd440,11'd550};
logic [0:9] [10:0] Y_positions = {11'd200,11'd320,11'd160,11'd200,11'd410,11'd330,11'd170,11'd380,11'd180,11'd180};
logic [0:9] draw_request = 10'h0;// holds a vector which corona should be drawn
logic [0:3] rand_index = 0;
// random locations, get in X/Y posions when draw request == 0
logic [0:9] [10:0] X_rand_positions = {11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0};
logic [0:9] [10:0] Y_rand_positions = {11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0, 11'd0};

always_ff@(posedge clk or negedge resetN)
begin
	X_positions<=X_positions; 
	Y_positions<=Y_positions;
	draw_request<= draw_request;
	
	
	if(!resetN) begin 
		X_positions<=INITIAL_X;
		Y_positions<=INITIAL_Y;
		draw_request<= 10'h0;
			
	end 
	else begin
		// insert new random locations after phase1 is over	 

		if ((IsInCircularMovement) && (EndOfPhase1) && (!draw_request)) begin
			X_positions <= X_rand_positions;
			Y_positions <= Y_rand_positions;
			draw_request <= rand_draw_request;
		end
				
		// collision calculations
		if (collision) begin
			if (collision_clamp_corona != 15) begin
				draw_request[collision_clamp_corona] <= 0;
			end
			X_rand_positions[rand_index] <= randX;
			Y_rand_positions[9-rand_index] <= randY;
			rand_index <= ((rand_index + 1) % 10);
			
		end
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = X_positions ;   // note it must be 2^n 
assign 	topLeftY = Y_positions ; 
assign Draw_request = draw_request;  


endmodule
