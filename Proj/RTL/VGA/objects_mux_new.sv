
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux_new	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     
		  // add the box here 
					input		logic [9:0]	vaccineDrawingRequest, // two set of inputs per unit
					input		logic	[9:0][7:0] vaccineRGB, 			  
			  
		  ////////////////////////
		  // background 
					input    logic HartDrawingRequest, // box of numbers
					input		logic	[7:0] hartRGB,   
					input		logic	[7:0] backGroundRGB, 
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (smileyDrawingRequest == 1'b1 )   
			RGBOut <= smileyRGB;  //first priority 
		 
		 
		 // add logic for box here 
		else if (vaccineDrawingRequest[0] == 1'b1 )  RGBOut <= vaccineRGB[0];  //second priority 
		else if (vaccineDrawingRequest[1] == 1'b1 )  RGBOut <= vaccineRGB[1];  //second priority 
		else if (vaccineDrawingRequest[2] == 1'b1 )  RGBOut <= vaccineRGB[2];  //second priority 
		else if (vaccineDrawingRequest[3] == 1'b1 )  RGBOut <= vaccineRGB[3];  //second priority 
		else if (vaccineDrawingRequest[4] == 1'b1 )  RGBOut <= vaccineRGB[4];  //second priority 
		else if (vaccineDrawingRequest[5] == 1'b1 )  RGBOut <= vaccineRGB[5];  //second priority 
		else if (vaccineDrawingRequest[6] == 1'b1 )  RGBOut <= vaccineRGB[6];  //second priority 
		else if (vaccineDrawingRequest[7] == 1'b1 )  RGBOut <= vaccineRGB[7];  //second priority 
		else if (vaccineDrawingRequest[8] == 1'b1 )  RGBOut <= vaccineRGB[8];  //second priority 
		else if (vaccineDrawingRequest[9] == 1'b1 )  RGBOut <= vaccineRGB[9];  //second priority 
		 
		else if (HartDrawingRequest == 1'b1) RGBOut <= hartRGB;
		else RGBOut <= backGroundRGB ; // last priority 
		end ; 
	end

endmodule


