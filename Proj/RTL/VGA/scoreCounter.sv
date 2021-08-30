

module	scoreCounter	(	
			input	logic	resetN,
			input	logic	up, 
			input	logic	down,
 
			
			output logic [3:0] dig1,
			output logic [3:0] dig2 
);



always_ff@(posedge up or posedge down or negedge resetN)
begin
	if(!resetN)
	begin 
		dig1	<= 3'b0;
		dig2	<= 3'b0; 
	end 
	
	else begin 
		if(up)
		begin
			if(dig1 == 9)
			begin
				dig1 <= 0;
				dig2 <= dig2 + 1;
			end
			else dig1 <= dig1 + 1;
		end
		
		if(down)
		begin
			if(dig1 == 0)
			begin
				dig1 <= 9;
				dig2 <= dig2 - 1;
			end
			else dig1 <= dig1 - 1;
		end
	end 
end

endmodule
