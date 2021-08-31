module sound_controller (

	input	logic clk,
	input	logic	resetN,
	input	logic [0:3] collision_clamp_corona,
	input logic [0:3] collision_clamp_vaccine,
	input logic startOfFrame,
	
	output logic [3:0] freq
);

logic [6:0] counter;
logic play_sad_sound = 0;
logic play_happy_sound = 0;

localparam int SILENT = 0;
localparam int FIRST_NOTE = 1;
localparam int SECOND_NOTE = 2;
localparam int THIRD_NOTE = 3;

logic [0:1] sound_ps = SILENT;
logic [0:1] sound_ns = SILENT;

localparam int SOL = 7;
localparam int RE = 2;
localparam int DOD = 1;
localparam int DO = 0;
localparam int FA = 5;
localparam int LA = 9;


always_ff@(posedge clk, negedge resetN) begin
	sound_ps <= sound_ps;
	sound_ns <= sound_ns;
	if (!resetN) begin
		counter <= 0;
		freq <= 0;
		play_sad_sound <= 0;
		play_happy_sound <= 0;
		sound_ps <= SILENT;
		sound_ns <= SILENT;
	end
	else begin
			if (collision_clamp_vaccine != 15) begin
				play_happy_sound <= 1;
			end
			if (collision_clamp_corona != 15) begin
				if (play_happy_sound) play_happy_sound <= 0;
				play_sad_sound <= 1;
			end
			if (startOfFrame && (play_sad_sound || play_happy_sound)) begin
				counter <= counter + 1;
				if (sound_ps == THIRD_NOTE) sound_ns <= SILENT;
				else sound_ns <= sound_ps + 1;
		
				if (counter == 90) begin
				counter <= 0;
				sound_ps <= sound_ns;
				end
		
				if (play_sad_sound && (sound_ps != SILENT))begin
					if (sound_ps == FIRST_NOTE) freq <= SOL;
					else if (sound_ps == SECOND_NOTE) freq <= RE;
					else freq <= DOD;
				end
		
				if (play_happy_sound && (sound_ps != SILENT))begin
					if (sound_ps == FIRST_NOTE) freq <= DO;
					else if (sound_ps == SECOND_NOTE) freq <= FA;
					else freq <= LA;
				end
				if (sound_ps == SILENT) begin
					play_sad_sound <= 0;
					play_happy_sound <= 0;
				end
			end
	end
end

endmodule
