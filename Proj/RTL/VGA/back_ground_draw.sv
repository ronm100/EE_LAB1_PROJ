//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2021


module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDrawReq 
);

const int	xFrameSize	=	635;
const int	yFrameSize	=	475;
const int	bracketOffset =	30;
const int   COLOR_MARTIX_SIZE  = 16*8 ; // 128 

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;
logic [10:0] shift_pixelX;


localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

 
localparam  int RED_TOP_Y  = 156 ;
localparam  int RED_LEFT_X  = 256 ;
localparam  int GREEN_RIGHT_X  = 32 ;
localparam  int BLUE_BOTTOM_Y  = 300 ;
localparam  int BLUE_RIGHT_X  = 200 ;

//mask parameters
localparam 	int MASK_UPPER_Y = 110;
localparam	int MASK_BOTTOM_Y = 360;
localparam	int TOP_WHITE_BOTTOM_Y = 130;
localparam	int BOTTOM_WHITE_TOP_Y = 345;
localparam	int PLEATS_LEFT_X = 95;
localparam	int PLEATS_RIGHT_X = 550;
localparam	int FIRST_PLEAT_TOP_Y = 170;
localparam	int SECOND_PLEAT_TOP_Y = 220;
localparam	int THIRD_PLEAT_TOP_Y = 270;
 
parameter  logic [10:0] COLOR_MATRIX_TOP_Y  = 100 ; 
parameter  logic [10:0] COLOR_MATRIX_LEFT_X = 100 ;

 

// this is a block to generate the background 
//it has four sub modules : 

	// 1. draw the yellow borders
	// 2. draw four lines with "bracketOffset" offset from the border 
	// 3.  draw red rectangle at the bottom right,  green on the left, and blue on top left 
	// 4. draw a matrix of 16*16 rectangles with all the colors, each rectsangle 8*8 pixels  	

 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	 
	end 
	else begin

	// defaults 
		greenBits <= 3'b101 ; 
		redBits <= 3'b111 ;
		blueBits <= 2'b10;
		boardersDrawReq <= 	1'b0 ; 

					
	// draw the yellow borders 
		if (pixelX == 0 || pixelY == 0  || pixelX == xFrameSize || pixelY == yFrameSize)
			begin 
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR ;	
				blueBits <= LIGHT_COLOR ;	// 3rd bit will be truncated
			end
		// draw  four lines with "bracketOffset" offset from the border 
		
		if (        pixelX == bracketOffset ||
						pixelY == bracketOffset ||
						pixelX == (xFrameSize-bracketOffset) || 
						pixelY == (yFrameSize-bracketOffset)) 
			begin 
					redBits <= DARK_COLOR ;	
					greenBits <= DARK_COLOR  ;	
					blueBits <= DARK_COLOR ;
					boardersDrawReq <= 	1'b1 ; // pulse if drawing the boarders 
			end
	
	// note numbers can be used inline if they appear only once 


	
	// 3.  draw red rectangle at the bottom right,  green on the left, and blue on top left 
	//-------------------------------------------------------------------------------------
		
//		if (pixelY > RED_TOP_Y && pixelX >= RED_LEFT_X ) // rectangles on part of the screen 
//				redBits <= DARK_COLOR ; 
//				 
//	
//		if (GREEN_RIGHT_X <  GREEN_RIGHT_X  ) 
//				greenBits <= 3'b011 ; 
//						
//		if (pixelX <  BLUE_RIGHT_X && pixelY < BLUE_BOTTOM_Y )   
//					blueBits <= 2'b10  ; 

//add mask
		if (((pixelY > MASK_UPPER_Y) && (pixelY < TOP_WHITE_BOTTOM_Y)) || ((pixelY > BOTTOM_WHITE_TOP_Y) && (pixelY < MASK_BOTTOM_Y))) begin
			redBits <= DARK_COLOR;
			greenBits <= DARK_COLOR;
			blueBits <= 2'b11;
		end
		
		if ((pixelY >= TOP_WHITE_BOTTOM_Y) && (pixelY <= BOTTOM_WHITE_TOP_Y)) begin
			redBits <= 3'b110;
			greenBits <= 3'b110;
			blueBits <= 2'b11;
		end
		
		if (((pixelY > FIRST_PLEAT_TOP_Y) && (pixelY < FIRST_PLEAT_TOP_Y +5)) && ((pixelX > PLEATS_LEFT_X) && (pixelX < PLEATS_RIGHT_X))) begin
			redBits <= 3'b000;
			greenBits <= 3'b000;
			blueBits <= 2'b11;
		end
		
		if (((pixelY > SECOND_PLEAT_TOP_Y) && (pixelY < SECOND_PLEAT_TOP_Y +5)) && ((pixelX > PLEATS_LEFT_X) && (pixelX < PLEATS_RIGHT_X))) begin
			redBits <= 3'b000;
			greenBits <= 3'b000;
			blueBits <= 2'b11;
		end
		
		if (((pixelY > THIRD_PLEAT_TOP_Y) && (pixelY < THIRD_PLEAT_TOP_Y +5)) && ((pixelX > PLEATS_LEFT_X) && (pixelX < PLEATS_RIGHT_X))) begin
			redBits <= 3'b000;
			greenBits <= 3'b000;
			blueBits <= 2'b11;
		end

				

	// 4. draw a matrix of 16*16 rectangles with all the colors, each rectsangle 8*8 pixels  	
   // ---------------------------------------------------------------------------------------
		if (( pixelY > 8 ) && (pixelY < 24 ) && (pixelX >30 )&& (pixelX <542 ))
		 begin
		        shift_pixelX<= pixelX-29;

             blueBits <= shift_pixelX[2:1] ; 
				 greenBits <= shift_pixelX[5:3] ; 
				 redBits <= shift_pixelX[8:6]; 
					
	
				
		 end 
		
//		if ((pixelX > COLOR_MATRIX_LEFT_X)  && (pixelX < COLOR_MATRIX_LEFT_X + COLOR_MARTIX_SIZE) 
//		&& ( pixelY > COLOR_MATRIX_TOP_Y) && (pixelY < COLOR_MATRIX_TOP_Y + COLOR_MARTIX_SIZE )) 
//		begin
//			 redBits <= pixelX[5:3] ; 
//			greenBits <= pixelY[5:3] ; 
//			blueBits <= { pixelX[6] , pixelY[6]} ; 
//			
//
//    
//				
//		end	

		
	BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 
			


	end; 	
end 
endmodule

