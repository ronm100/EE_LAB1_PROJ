
// game controller dudy Febriary 2	2	
// (c) Technion IIT, Department of Electrical Engineering 2	21 
//updated --Eyal Lev 2	21


module	game_controller_all	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 3	Hz 
			input	logic	drawing_request_Ball,
			input	logic	drawing_request_1,
			input	logic	[0:9] drawing_request_vaccine,
			input logic [0:9] drawing_request_corona,
			input logic [0:9] current_vaccines, //holds which vaccines are activated in the whole game
       // add the box here 
			
			output logic [0:3] collision_clamp_vaccine, // number of the possition of the collision
			output logic collision, // active in case of collision between two objects
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
			output logic [0:3] collision_clamp_corona,
			output logic EndOfPhase1, //all of the first vaccines where captured 
			output logic  upCounter,
			output logic  downCounter
);

// drawing_request_Ball   -->  smiley
// drawing_request_1      -->  brackets
// drawing_request_2      -->  number/box 
//logic collision_smiley_number;

always_comb
begin
   //vaccine
	if ( drawing_request_Ball &&  drawing_request_vaccine[0] ) collision_clamp_vaccine = 0;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[1] ) collision_clamp_vaccine = 1;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[2] ) collision_clamp_vaccine = 2;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[3] ) collision_clamp_vaccine = 3;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[4] ) collision_clamp_vaccine = 4;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[5] ) collision_clamp_vaccine = 5;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[6] ) collision_clamp_vaccine = 6;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[7] ) collision_clamp_vaccine = 7;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[8] ) collision_clamp_vaccine = 8;
	else if ( drawing_request_Ball &&  drawing_request_vaccine[9] ) collision_clamp_vaccine = 9;
	else collision_clamp_vaccine = 15; //should not get here- error code
	
	//corona
	if ( drawing_request_Ball &&  drawing_request_corona[0] ) collision_clamp_corona = 0;
	else if ( drawing_request_Ball &&  drawing_request_corona[1] ) collision_clamp_corona = 1;
	else if ( drawing_request_Ball &&  drawing_request_corona[2] ) collision_clamp_corona = 2;
	else if ( drawing_request_Ball &&  drawing_request_corona[3] ) collision_clamp_corona = 3;
	else if ( drawing_request_Ball &&  drawing_request_corona[4] ) collision_clamp_corona = 4;
	else if ( drawing_request_Ball &&  drawing_request_corona[5] ) collision_clamp_corona = 5;
	else if ( drawing_request_Ball &&  drawing_request_corona[6] ) collision_clamp_corona = 6;
	else if ( drawing_request_Ball &&  drawing_request_corona[7] ) collision_clamp_corona = 7;
	else if ( drawing_request_Ball &&  drawing_request_corona[8] ) collision_clamp_corona = 8;
	else if ( drawing_request_Ball &&  drawing_request_corona[9] ) collision_clamp_corona = 9;
	else collision_clamp_corona = 15; //should not get here- error code
	
	//Scoreboard
	if(collision_clamp_vaccine != 15) upCounter = 1;
	else upCounter = 0;
	if(collision_clamp_corona != 15) downCounter = 1;
	else downCounter = 0;
end

//assign collision_clamp_vaccine = ( drawing_request_Ball &&  drawing_request_vaccine );
assign collision = (( drawing_request_Ball && drawing_request_1) || (collision_clamp_vaccine != 15) || (collision_clamp_corona != 15) );// any collision 
						 						
						
// add colision between number and Smiley


logic flag; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin


	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ;
		EndOfPhase1 <= 1'b0;
	end 
	else begin 
			if (!current_vaccines) EndOfPhase1 <= 1'b1;
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
				
//		change the section below  to collision between number and smiley


	if ( collision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		end ; 
	end 
end

endmodule
