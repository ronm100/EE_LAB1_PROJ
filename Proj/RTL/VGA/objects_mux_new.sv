
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
					input		logic	clampDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] clampRGB, 
			  
		  // add the box here 
					input		logic [0:9]	vaccineDrawingRequest, // two set of inputs per unit
					input		logic	[0:9][7:0] vaccineRGB,
			  
		  ////////////////////////
		  // background 
    
					

					input		logic	[7:0] backGroundRGB,
					input		logic [0:9] coronaDrawingRequest,
					input		logic [0:9][7:0] coronaRGB,
					
					// line
					input		logic	lineDR,
					
			// Scoreboard
					input		logic	dig1DR,
					input		logic	dig2DR,
					input		logic	[7:0] dig1RGB,
					input		logic	[7:0] dig2RGB,
					
					// benet
					input		logic BenetDR,
					input		logic [7:0] BenetRGB,
					
			//Timeout
					input logic timeout,
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (clampDrawingRequest == 1'b1 )   
			RGBOut <= clampRGB;  //first priority 
		 
		 
		 // add logic for box here
		else if (coronaDrawingRequest[0] == 1'b1 )  RGBOut <= coronaRGB[0];  //second priority 
		else if (coronaDrawingRequest[1] == 1'b1 )  RGBOut <= coronaRGB[1];  //second priority 
		else if (coronaDrawingRequest[2] == 1'b1 )  RGBOut <= coronaRGB[2];  //second priority 
		else if (coronaDrawingRequest[3] == 1'b1 )  RGBOut <= coronaRGB[3];  //second priority 
		else if (coronaDrawingRequest[4] == 1'b1 )  RGBOut <= coronaRGB[4];  //second priority 
		else if (coronaDrawingRequest[5] == 1'b1 )  RGBOut <= coronaRGB[5];  //second priority 
		else if (coronaDrawingRequest[6] == 1'b1 )  RGBOut <= coronaRGB[6];  //second priority 
		else if (coronaDrawingRequest[7] == 1'b1 )  RGBOut <= coronaRGB[7];  //second priority 
		else if (coronaDrawingRequest[8] == 1'b1 )  RGBOut <= coronaRGB[8];  //second priority 
		else if (coronaDrawingRequest[9] == 1'b1 )  RGBOut <= coronaRGB[9];  //second priority
		
		
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
		else if (BenetDR) RGBOut <= BenetRGB;
		else if(lineDR) RGBOut <=8'hfb;
		else if(dig1DR) RGBOut <= dig1RGB;
		else if(dig2DR) RGBOut <= dig2RGB;
		else RGBOut <= backGroundRGB ; // last priority 
		
		//Timeout
		if(timeout)
		begin
			if(dig1DR) RGBOut <= dig1RGB;
			else if(dig2DR) RGBOut <= dig2RGB;
			else RGBOut <= backGroundRGB ;
		end
		
		end ; 
	end

endmodule


