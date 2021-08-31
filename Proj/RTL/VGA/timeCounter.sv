

module	timeCounter	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	oneSec,
 
			
			output logic [3:0] dig1,
			output logic [3:0] dig2,
			output logic [3:0] dig3,
			output logic timeIsUp //Goes up when the timer reaches 0;
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		dig1	<= 0;
		dig2	<= 8; 
		dig3	<= 1;
		timeIsUp <= 0;
	end 
	
	else begin 
		
		if(oneSec)
		begin
			if(dig1 != 0) dig1 <= dig1 - 1;
			else
			begin
				dig1 <= 9;
				if(dig2 != 0)dig2 <= dig2 - 1;
				else
				begin
					dig2 <= 9;
					if(dig3 != 0) dig3 <= 0;
					else
					begin
						timeIsUp <= 1;
						dig1 <= 0;
						dig2 <= 0;
					end
				end
			end
		end
	end 
end

endmodule
