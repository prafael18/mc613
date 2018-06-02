# Battleship
#### Battleship implementation for Cyclone V SoC in VHDL using Quartus II
Since battleship is a two-player game, there are a few small considerations to make when adapting the code for each player. To maintain compiled code for each player, two Quartus projects where created with the following differences:

1. GPIO ports are inverted for UART communication, meaning for one player RX is GPIO\_0[0] and TX is GPIO\_0[1] while for the other player RX is GPIO\_0[1] and TX is GPIO\_0[0].
2. Memory initialization files are different. One uses initial_map_p1.mif while the other uses initial\_map\_p2.mif.
3. Initial state in entity player's FSM is different. The starting player should have wait\_click as his initial state while his oponnent should wait for his turn in the initial state wait_turn.
MIF file must correspond to player.

Each player has it's own folder, **battleship** or **battleship_p2**, with the changes mentioned above implemented accordingly. Another consideration is that there's a folder named MIF only inside the **battleship** folder. Within this folder are all of the files necessary to generate the MIFs used throughout the project. In order to play the game, one would have to tinker with the player maps in the files player1.txt and player2.txt and then proceed to run `python3 genmif.py` in a shell. 

