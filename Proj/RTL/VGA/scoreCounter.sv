

module	scoreCounter	(	
			input	logic	resetN,
			input	logic	up, 
			input	logic	down,
			input	logic	clk,
 
			
			output logic [3:0] dig1,
			output logic [3:0] dig2 
);

logic [3:0] counter;
logic flag;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		dig1	<= 3'b0;
		dig2	<= 3'b0; 
		counter <= 0;
		flag <= 1;
	end 
	
	else begin 
		counter <= (counter + 1) % 4;
		if((counter == 0) && (flag == 0)) flag <= 1;
		if(up && flag)
		begin
			flag <= 0;
			if(dig1 == 9)
			begin
				dig1 <= 0;
				dig2 <= dig2 + 1;
			end
			else dig1 <= dig1 + 1;
		end
		
		if(down && flag)
		begin
			flag <= 0;
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
