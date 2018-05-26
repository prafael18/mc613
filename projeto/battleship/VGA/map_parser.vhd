library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity map_parser is
  port (    
    CLOCK_50                  : in  std_logic;
    KEY                       : in  std_logic_vector(0 downto 0);
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic;
    vga_data_in					: in  std_logic_vector(7 downto 0);
	 vga_rd_addr					: out natural range 0 to 2**15 - 1);
end map_parser;

architecture comportamento of map_parser is

	component screen_memory is
	  port (
		 clk : in std_logic;
		 data_in : in std_logic_vector(2 downto 0);
		 data_out : out std_logic_vector(2 downto 0);
		 reg_rd : in integer range 0 to 128*96-1;
		 reg_wr : in integer range 0 to 128*96-1;
		 we : in std_logic;
		 clear : in std_logic
	  );
	end component;
  
  signal rstn : std_logic;              -- reset active low para nossos
                                        -- circuitos sequenciais.

--  signal vga_data_in: std_logic_vector (7 downto 0);
--  signal vga_rd_addr: natural range 0 to 2**15-1;
--  signal tmp:	std_logic_vector(7 downto 0);
  -- Interface com a memória de vídeo do controlador

  signal we : std_logic;                        -- write enable ('1' p/ escrita)
  signal addr : integer range 0 to 12287;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel
  
  -- Sinais dos contadores de linhas e colunas utilizados para percorrer
  -- as posições da memória de vídeo (pixels) no momento de construir um quadro.
  
  signal line : integer range 0 to 95;  -- linha atual
  signal col : integer range 0 to 127;  -- coluna atual

  -- Especificação dos tipos e sinais da máquina de estados de controle
  type estado_t is (inicio, refresh, build_map);
  signal estado: estado_t := inicio;
  signal proximo_estado: estado_t := inicio;  --The true initial state is proximo_estado, 
															 --since a change in estado is what triggers the process.
  
  -- Sinais para um contador utilizado para atrasar a atualização da
  -- posição da bola, a fim de evitar que a animação fique excessivamente
  -- veloz. Aqui utilizamos um contador de 0 a 1250000, de modo que quando
  -- alimentado com um clock de 50MHz, ele demore 25ms (40fps) para contar até o final.
  
  signal contador : integer range 0 to 1250000 - 1;  -- contador
  signal timer : std_logic;        -- vale '1' quando o contador chegar ao fim
  signal timer_rstn, timer_enable : std_logic;
  
  signal sync, blank: std_logic;
  
  -- Signals that communicate with main memory
--  signal rd_addr: natural range 0 to 2**15 - 1;
--  signal data_out: std_logic_vector(7 downto 0);
  
  -- Player flags and aux color signal
  signal player1 : std_logic;
  signal player2: std_logic;
  signal color: std_logic_vector(2 downto 0);
  
  signal map_rd_addr: natural range 0 to 2**15 - 1;
  signal text_rd_addr: natural range 0 to 2**15-1;
  
  signal text_enable: std_logic;      -- enable da escrita do titulo no mapa
  signal map_rstn : std_logic; 			-- reset do contador de posicoes no mapa
  signal map_enable: std_logic; 			-- enable do contador de posicoes no mapa

  signal end_map_write : std_logic;       -- '1' quando terminou de desenhar os mapas
  signal end_text_write: std_logic;       -- '1' quando terminou de desenhar o titulo e legenda

  signal map_line, text_line : integer range 0 to 95;
  signal map_col, text_col   : integer range 0 to 127;

  begin  -- comportamento
		
--  	main_memory: entity work.memory
--	generic map
--	  (DATA_WIDTH => 8,
--		ADDR_WIDTH => 15,
--		MIF_FILE => "Memory/initial_map.mif")
--	port map 
--	  (clk	 => CLOCK_50,
--		addr_a => vga_rd_addr,
--		addr_b => 0,
--		data_a => "00000000",
--		data_b => "00000000",
--		we_a 	 => '0',
--		we_b 	 => '0',
--		q_a	 => vga_data_in,
--		q_b 	 => tmp);
		
  -- Aqui instanciamos o controlador de vídeo, 128 colunas por 96 linhas
  -- (aspect ratio 4:3). Os sinais que iremos utilizar para comunicar
  -- com a memória de vídeo (para alterar o brilho dos pixels) são
  -- write_clk (nosso clock), write_enable ('1' quando queremos escrever
  -- o valor de um pixel), write_addr (endereço do pixel a escrever)
  -- e data_in (valor do brilho do pixel RGB, 1 bit pra cada componente de cor)
  vga_controller: entity work.vgacon port map (
    clk50M       => CLOCK_50,
    rstn         => '1',
    red          => VGA_R,
    green        => VGA_G,
    blue         => VGA_B,
    hsync        => VGA_HS,
    vsync        => VGA_VS,
    write_clk    => CLOCK_50,
    write_enable => we,
    write_addr   => addr,
    data_in      => pixel,
    vga_clk      => VGA_CLK,
    sync         => sync,
    blank        => blank);
  VGA_SYNC_N <= NOT sync;
  VGA_BLANK_N <= NOT blank;

  
  -- Player 1 origin = (23, 9)
  -- Player 2 origin = (25, 9)
  
  -- Origin for battleship in main memory is (2,0)
  -- Origin for battleship is (8,34) in VGA display.
  -- Origin for labels in main memory is (7,0)
  -- Origin for labels is (75,10) in VGA display.
  draw_title: process (CLOCK_50)
	variable text_rd_col : integer := 0;
	variable text_rd_line: integer := 0;
	variable title_count : integer  := 0;
	variable labels_count : integer := 0;
  begin
	if CLOCK_50'event and CLOCK_50 = '1' then
		if text_enable = '1' then 
			if title_count < 128*5 then
				end_text_write <= '0';
				text_rd_line := title_count/128;
				text_rd_col  := title_count mod 128;
				text_line <= text_rd_line + 8;
				text_col <= text_rd_col;
				text_rd_addr <= (128*(2+text_rd_line) + text_rd_col);
				title_count := title_count + 1;
			elsif title_count = 128*5 and labels_count < 128*12 then
				end_text_write <= '0';
				text_rd_line := labels_count/128;
				text_rd_col  := labels_count mod 128;
				text_line <= text_rd_line + 75;
				text_col <= text_rd_col;
				text_rd_addr <= (128*(7+text_rd_line) + text_rd_col);
				labels_count := labels_count + 1;
			else
				end_text_write <= '1';
			end if;
		end if;
	end if;
  end process draw_title;
  
--  end_text_write <= '1' when title_count = 128*5 and labels_count = 128*12 else '0';
  
  construct_map: process (CLOCK_50, map_rstn)
		variable player1_count : integer := 0;
		variable player2_count : integer := 0;
		variable player1_origin_x : integer := 0;
		variable player1_origin_y : integer := 0;
		variable player2_origin_x : integer := 0;
		variable player2_origin_y : integer := 0;
		variable clock_counter : integer := 0;
	begin
		if map_rstn = '0' then
			player1_count := 0;
			player2_count := 0;
			clock_counter := 0;
		elsif CLOCK_50'event and CLOCK_50 = '1' then
			if map_enable = '1' then
				if player1_count < 100 then
					player1 <= '1';
					player2 <= '0';
					if clock_counter < 25 then
						map_rd_addr <= player1_count;
						player1_origin_x := 9 + 5 * (player1_count mod 10);
						player1_origin_y := 23 + 5 * (player1_count / 10 );
						map_col <= player1_origin_x + (clock_counter mod 5);
						map_line <= player1_origin_y + (clock_counter / 5);
						clock_counter := clock_counter + 1;
					elsif clock_counter = 25 then
						clock_counter := 0;
						player1_count := player1_count + 1;
					end if;				
				elsif player1_count = 100 and player2_count < 100 then
					player1 <= '0';
					player2 <= '1';
					if clock_counter < 25 then
						map_rd_addr <= (1*128) + player2_count;
						player2_origin_x := 69 + 5 * (player2_count mod 10);
						player2_origin_y := 23 + 5 * (player2_count / 10 );
						map_col <= player2_origin_x + (clock_counter mod 5);
						map_line <= player2_origin_y + (clock_counter / 5);
						clock_counter := clock_counter + 1;
					elsif clock_counter = 25 then
						clock_counter := 0;
						player2_count := player2_count + 1;
					end if;
				else
					player1_count := 0;
					player2_count := 0;
					clock_counter := 0;
					player1 <= '0';
					player2 <= '0';
					map_col <= 127;
					map_line <= 95;
				end if;
			end if;
		end if;
	end process construct_map;
				

  -- Este sinal é útil para informar nossa lógica de controle quando
  -- terminamos de desenhar o mapa.
  end_map_write <= '1' when (map_col = 127 and map_line = 95)
                 else '0'; 

  -----------------------------------------------------------------------------
  -- Abaixo estão processos relacionados com a atualização da posição da
  -- bola. Todos são controlados por sinais de enable de modo que a posição
  -- só é de fato atualizada quando o controle (uma máquina de estados)
  -- solicitar.
  -----------------------------------------------------------------------------

  
  -- purpose: Este processo irá atualizar a coluna atual da bola,
  --          alterando sua posição no próximo quadro a ser desenhado.
  -- type   : sequential
  -- inputs : CLOCK_50, rstn
  -- outputs: pos_x
  
  -- Reads from the same address we're writing to
  -- Player 1 origin is (23, 9)
  -- Player 2 origin is (25, 9)
  
  -- We are player 1
  -- Player 1 map has 3 colors:
  -- Water is always blue.
  -- Uncharted ship is green.
  -- Discovered ship is red.
  
  -- Player 2 map has 3 colors:
  -- Anything undiscovered is white
  -- Discovered water is blue
  -- Discovered ship is red
  
  -- Flags read from main memory are:
  -- 0x1 = is_ship 
  -- 0x2 = is_water
  -- 0x4 = is_charted_ship
  -- 0x8 = is_charted water
  
  set_color: process(map_col, map_line)
	variable ship_flag: std_logic;
	variable water_flag: std_logic;
	variable charted_water_flag: std_logic;
	variable charted_ship_flag: std_logic;
  begin
	
	--Set flags
	ship_flag := vga_data_in(0);
	water_flag := vga_data_in(1);
	charted_water_flag := vga_data_in(2);
	charted_ship_flag := vga_data_in(3);
	
	if player1 = '1' then
		if water_flag = '1' then
			color <= "001"; --BLUE
		elsif ship_flag = '1' then
			if charted_ship_flag = '1' then
				color <= "100"; -- RED
			else
				color <= "010"; -- GREEN
			end if;
		end if;
	elsif player2 = '1' then
		if charted_water_flag = '1' then
			color <= "001"; --BLUE
		elsif charted_ship_flag = '1' then
			color <= "100"; -- RED
		else
			color <= "111"; -- WHITE
		end if;
	else
		color <= "000"; --BLACK
	end if;
  end process;
			
  vga_rd_addr <= map_rd_addr  when map_enable = '1' else
				 text_rd_addr when text_enable = '1' else
				 0;
  
  pixel <= color 			   			when map_enable = '1' else
			  vga_data_in(2 downto 0) 	when text_enable = '1' else
			  "000";

  col   <= map_col  when map_enable = '1' else
			  text_col when text_enable = '1' else
			  0;
			  
  line  <= map_line  when map_enable = '1' else
			  text_line when text_enable = '1' else 
			  0;

  -- O endereço de memória pode ser construído com essa fórmula simples,
  -- a partir da linha e coluna atual
  addr  <= col + (128* line);

  -----------------------------------------------------------------------------
  -- Processos que definem a FSM (finite state machine), nossa máquina
  -- de estados de controle.
  -----------------------------------------------------------------------------

  -- purpose: Esta é a lógica combinacional que calcula sinais de saída a partir
  --          do estado atual e alguns sinais de entrada (Máquina de Mealy).
  -- type   : combinational
  -- inputs : estado, end_map_write, timer
  -- outputs: proximo_estado, atualiza_pos_x, atualiza_pos_y, line_rstn,
  --          line_enable, col_rstn, col_enable, we, timer_enable, timer_rstn
  logica_mealy: process (estado, end_map_write, end_text_write, timer)
  begin  -- process logica_mealy
    case estado is
		when inicio				=> if end_text_write = '1' then
											proximo_estado <= refresh;
										end if;
										text_enable  <= '1';
										map_rstn 	 <= '0';
										map_enable   <= '0';
										we				 <= '1';
										timer_rstn   <= '0';
										timer_enable <= '0';
										 
      when refresh         => if timer = '1' then 
                               proximo_estado <= build_map;
                             else
                               proximo_estado <= refresh;
                             end if;
									  text_enable    <= '0';
									  map_rstn		  <= '0'; -- reset eh active low.
									  map_enable     <= '1';
                             we             <= '0';
                             timer_rstn     <= '1';  -- reset é active low!
                             timer_enable   <= '1';

      when build_map			=>if end_map_write = '1' then
                               proximo_estado <= refresh;
									  end if;
									  text_enable    <= '0';
  									  map_rstn  	  <= '1';
									  map_enable 	  <= '1';
                             we             <= '1';
                             timer_rstn     <= '0'; 
                             timer_enable   <= '0';
									  
      when others         => proximo_estado <= inicio;
									  text_enable    <= '0';
									  map_rstn 		  <= '1';
									  map_enable     <= '0';
                             we             <= '0';
                             timer_rstn     <= '1'; 
                             timer_enable   <= '0';
      
    end case;
  end process logica_mealy;
  
  -- purpose: Avança a FSM para o próximo estado
  -- type   : sequential
  -- inputs : CLOCK_50, rstn, proximo_estado
  -- outputs: estado
  seq_fsm: process (CLOCK_50, rstn)
  begin  										 				-- process seq_fsm
    if rstn = '0' then                  				-- asynchronous reset (active low)
      estado <= inicio;
    elsif CLOCK_50'event and CLOCK_50 = '1' then   -- rising clock edge
      estado <= proximo_estado;
    end if;
  end process seq_fsm;

  -----------------------------------------------------------------------------
  -- Processos do contador utilizado para atrasar a animação (evitar
  -- que a atualização de quadros fique excessivamente veloz).
  -----------------------------------------------------------------------------
  -- purpose: Incrementa o contador a cada ciclo de clock
  -- type   : sequential
  -- inputs : CLOCK_50, timer_rstn
  -- outputs: contador, timer
  p_contador: process (CLOCK_50, timer_rstn)
  begin  -- process p_contador
    if timer_rstn = '0' then            -- asynchronous reset (active low)
      contador <= 0;
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      if timer_enable = '1' then       
        if contador = 1250000 - 1 then
          contador <= 0;
        else
          contador <=  contador + 1;        
        end if;
      end if;
    end if;
  end process p_contador;

  -- purpose: Calcula o sinal "timer" que indica quando o contador chegou ao
  --          final
  -- type   : combinational
  -- inputs : contador
  -- outputs: timer
  p_timer: process (contador)
  begin  -- process p_timer
    if contador = 1250000 - 1 then
      timer <= '1';
    else
      timer <= '0';
    end if;
  end process p_timer;

  -----------------------------------------------------------------------------
  -- Processos que sincronizam sinais assíncronos, de preferência com mais
  -- de 1 flipflop, para evitar metaestabilidade.
  -----------------------------------------------------------------------------
  
  -- purpose: Aqui sincronizamos nosso sinal de reset vindo do botão da DE1
  -- type   : sequential
  -- inputs : CLOCK_50
  -- outputs: rstn
  build_rstn: process (CLOCK_50)
    variable temp : std_logic;          -- flipflop intermediario
  begin  -- process build_rstn
    if CLOCK_50'event and CLOCK_50 = '1' then  -- rising clock edge
      rstn <= temp;
      temp := KEY(0);      
    end if;
  end process build_rstn;

  
end comportamento;