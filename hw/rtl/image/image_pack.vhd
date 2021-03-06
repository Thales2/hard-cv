--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all ;


library work ;
use work.utils_pack.all ;

package image_pack is


--constant
constant QVGA_WIDTH : natural := 320;
constant VGA_WIDTH : natural := 640;
constant QVGA_HEIGHT : natural := 240;
constant VGA_HEIGHT : natural := 480;

--types
type FRAME_FORMAT is (VGA, QVGA);
type CAMERA_TYPE is (OV7670, OV7725);
type matNM is array (natural range<>, natural range<>) of signed(8 downto 0);
type imatNM is array (natural range<>, natural range<>) of integer range -256 to 255;
type bmatNM is array (natural range<>, natural range<>) of std_logic;
type row3 is array (0 to 2) of signed(8 downto 0);
type mat3 is array (0 to 2) of row3;
type irow3 is array (0 to 2) of integer range -256 to 255;
type imat3 is array (0 to 2) of irow3;

type duplet is array (0 to 1) of integer range 0 to 3;
type index_array is array (0 to 8) of duplet ;
type pix_neighbours is array (0 to 3) of unsigned(7 downto 0);




component yuv_rgb is
port( clk	:	in std_logic ;
		resetn	:	in std_logic ;
		pixel_clock, hsync, vsync : in std_logic; 
		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_y : in std_logic_vector(7 downto 0) ;
		pixel_u : in std_logic_vector(7 downto 0) ;
		pixel_v : in std_logic_vector(7 downto 0) ;
		pixel_r : out std_logic_vector(7 downto 0) ;
		pixel_g : out std_logic_vector(7 downto 0)  ;
		pixel_b : out std_logic_vector(7 downto 0)  
);
end component;

component video_switch is
generic(NB	:	positive := 2);
port(pixel_clock, hsync, vsync : in std_logic_vector(NB - 1 downto 0);
	  pixel_data	:	in slv8_array(NB - 1 downto 0);
	  pixel_clock_out, hsync_out, vsync_out : out std_logic ;
	  pixel_data_out	:	out std_logic_vector(7 downto 0);
	  channel	:	in std_logic_vector(7 downto 0)
);
end component;

component threshold is
generic(INVERT : natural := 0; VALUE : std_logic_vector(7 downto 0) := X"FF");
port( 
 		pixel_data_in : in std_logic_vector(7 downto 0) ;
		threshold	:	in std_logic_vector(7 downto 0);
		pixel_data_out : out std_logic_vector(7 downto 0) 
);
end component;

component synced_binarization is
port( clk	:	in std_logic ;
		resetn	:	in std_logic ;
		pixel_clock, hsync, vsync : in std_logic; 
		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_1 : in std_logic_vector(7 downto 0) ;
		pixel_data_2 : in std_logic_vector(7 downto 0) ;
		pixel_data_3 : in std_logic_vector(7 downto 0) ;
		upper_bound_1	:	in std_logic_vector(7 downto 0);
		upper_bound_2	:	in std_logic_vector(7 downto 0);
		upper_bound_3	:	in std_logic_vector(7 downto 0);
		lower_bound_1	:	in std_logic_vector(7 downto 0);
		lower_bound_2	:	in std_logic_vector(7 downto 0);
		lower_bound_3	:	in std_logic_vector(7 downto 0);
		pixel_data_out : out std_logic_vector(7 downto 0) 
);
end component;

component rgb2hsv is
port( 
		clk : in std_logic; 
 		resetn : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_r, pixel_g, pixel_b : in std_logic_vector(4 downto 0 ); 
 		pixel_h, pixel_s, pixel_v : out std_logic_vector(7 downto 0 )
);
end component;

component pixel_counter is
		generic(POL : std_logic := '0'; MAX : positive := 640);
		port(
			clk : in std_logic; 
			resetn : in std_logic; 
			pixel_clock, hsync : in std_logic; 
			pixel_count : out std_logic_vector((nbit(MAX) - 1) downto 0 )
			);
end component;

component line_counter is
		generic(POL : std_logic := '1'; MAX : positive := 480);
		port(
			clk : in std_logic; 
			resetn : in std_logic; 
			hsync, vsync : in std_logic; 
			line_count : out std_logic_vector((nbit(MAX) - 1) downto 0 )
			);
end component;

component neighbours is
		generic(WIDTH : natural := 640; HEIGHT : natural := 480);
		port(
			clk : in std_logic; 
			resetn, sraz : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic; 
			neighbour_in : in unsigned(7 downto 0 );
			neighbours : out pix_neighbours);
end component;

component matNxM_latch is
	generic (N : natural := 3 ; M : natural := 3);
    Port ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
           sraz : in  STD_LOGIC;
           en : in  STD_LOGIC;
           d : in  matNM(0 to N-1, 0 to  M-1);
           q : out matNM(0 to N-1, 0 to  M-1));
end component;

component mat3x3_latch is
    Port ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
           sraz : in  STD_LOGIC;
           en : in  STD_LOGIC;
           d : in  mat3;
           q : out mat3);
end component;

component line_ram is
	generic(LINE_SIZE : natural := 640; ADDR_SIZE : natural := 10);
	port(
 		clk : in std_logic; 
 		we, en : in std_logic; 
 		data_out : out std_logic_vector(15 downto 0 ); 
 		data_in : in std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(ADDR_SIZE - 1 downto 0 )
	); 
end component;

component hsvdivrom is
	port(
	   clk, en	:	in std_logic ;
 		data : out std_logic_vector(15 downto 0 ); 
 		addr : in std_logic_vector(4 downto 0 )
	); 
end component;

component down_scaler is
	generic(SCALING_FACTOR : natural := 8; INPUT_WIDTH : natural := 640; INPUT_HEIGHT : natural := 480 );
	port(
 		clk : in std_logic; 
 		resetn : in std_logic; 
 		pixel_clock, hsync, vsync : in std_logic; 
 		pixel_clock_out, hsync_out, vsync_out : out std_logic; 
 		pixel_data_in : in std_logic_vector(7 downto 0 ); 
 		pixel_data_out : out std_logic_vector(7 downto 0 )
	); 
end component;

component conv3x3 is
generic(KERNEL : imatNM(0 to 2, 0 to 2) := ((1, 2, 1),(0, 0, 0),(-1, -2, -1));
		  NON_ZERO	: index_array := ((0, 0), (0, 1), (0, 2), (2, 0), (2, 1), (2, 2), (3, 3), (3, 3), (3, 3) ); -- (3, 3) indicate end  of non zero values
		  IS_POWER_OF_TWO : natural := 0 -- (3, 3) indicate end  of non zero values
		  );
port(
 		clk : in std_logic; 
 		resetn : in std_logic; 
 		new_block : in std_logic ;
		block3x3 : in matNM(0 to 2, 0 to 2);
		new_conv : out std_logic ;
		busy : out std_logic ;
 		abs_res : out std_logic_vector(7 downto 0 );
		raw_res : out signed(15 downto 0 )
);
end component;

component blockNxN is
		generic(WIDTH: natural := 640;
		  HEIGHT: natural := 480;
		  N: natural :=3);
		port(
			clk : in std_logic; 
			resetn : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic; 
			pixel_data_in : in std_logic_vector(7 downto 0 ); 
			new_block : out std_logic ;
			block_out : out matNM(0 to N-1, 0 to N-1));
end component;

component block3X3_pixel_pipeline is
		generic(WIDTH: natural := 640;
		  HEIGHT: natural := 480);
		port(
			resetn : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic;
			pixel_clock_out, hsync_out, vsync_out : out std_logic;
			pixel_data_in : in std_logic_vector(7 downto 0 ); 
			block_out : out matNM(0 to 2, 0 to 2));
end component;

component block3X3_pixel_pipeline_sp is
		generic(WIDTH: natural := 640;
		  HEIGHT: natural := 480);
		port(
			resetn : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic;
			pixel_clock_out, hsync_out, vsync_out : out std_logic;
			pixel_data_in : in std_logic_vector(7 downto 0 ); 
			block_out : out matNM(0 to 2, 0 to 2));
end component;

component block3X3 is
		generic(WIDTH: natural := 640;
		  HEIGHT: natural := 480);
		port(
			clk : in std_logic; 
			resetn : in std_logic; 
			pixel_clock, hsync, vsync : in std_logic; 
			pixel_data_in : in std_logic_vector(7 downto 0 ); 
			new_block : out std_logic ;
			block_out : out matNM(0 to 2, 0 to 2));
end component;

component binarization is
generic(INVERT : natural := 0; VALUE : std_logic_vector(7 downto 0) := X"FF");
port( 
 		pixel_data_in : in std_logic_vector(7 downto 0) ;
		upper_bound	:	in std_logic_vector(7 downto 0);
		lower_bound	:	in std_logic_vector(7 downto 0);
		pixel_data_out : out std_logic_vector(7 downto 0) 
);
end component;

component fifo2pixel is
	generic(WIDTH : positive := 320 ; HEIGHT : positive := 240);
	port(
		clk, resetn : in std_logic ;
		
		
		-- fifo side
		line_available : in std_logic ;	
		fifo_rd : out std_logic ;
		fifo_data : in std_logic_vector(15 downto 0);
		
		y_data : out std_logic_vector(7 downto 0 );  
 		pixel_clock_out, hsync_out, vsync_out : out std_logic
	
	);
end component;


component pixel2fifo is
generic(ADD_SYNC : boolean := false);
port(
	clk, resetn : in std_logic ;
	pixel_clock, hsync, vsync : in std_logic; 
	pixel_data_in : in std_logic_vector(7 downto 0);
	fifo_data : out std_logic_vector(15 downto 0);
	fifo_wr : out std_logic 

);
end component;


component yuv_pixel2fifo is
port(
	clk, resetn : in std_logic ;
	pixel_clock, hsync, vsync : in std_logic; 
	pixel_y, pixel_u, pixel_v : in std_logic_vector(7 downto 0);
	fifo_data : out std_logic_vector(15 downto 0);
	fifo_wr : out std_logic 

);
end component;

end image_pack;

package body image_pack is
 
end image_pack;
