# Params
import numpy as np

# 7 - WHITE
# 6 - YELLOW
# 5 - PINK
# 4 - RED
# 3 - LIGHT BLUE (CYAN)
# 2 - GREEN
# 1 - BLUE
# 0 - BLACK

#BATTLESHIP
# All letters should fit inside a 5x5 matrix

# word_size = 8
# bits_addr = 15

word_size = 8
bits_addr = 15

max_col = 128
max_line = 96

CENTER = 'X'
RIGHT = '>'
LEFT = '<'
UPPER = '^'
LOWER = '_'
SINGLE = '@'
WATER = '-'

BLACK = bin(0).split('b')[1].zfill(word_size)
BLUE = bin(1).split('b')[1].zfill(word_size)
RED = bin(4).split('b')[1].zfill(word_size)
GREEN = bin(2).split('b')[1].zfill(word_size)

SHIP_BODY = bin(1).split('b')[1].zfill(word_size)
WATER_BODY = bin(2).split('b')[1].zfill(word_size)

filenames = ["../Memory/initial_map_p1.mif", "../Memory/initial_map_p2.mif"]
# filenames = ["../VGA/vga_mem_2.mif"]

def gen_alphabet(alphabet):
    with open("alphabet.txt") as f:
        out = f.readlines()
        line_buffer = []
        for l in out:
            if "-" in l:
                origins = []
                char = l.split('-')[0]
                font_x = int(l.split('-')[1])
                font_y = int(l.split('-')[2])
                for i in range(font_y):
                    for j in range(font_x):
                        if line_buffer[i][j] == 'X':
                            origins.append((i,j))
                        elif line_buffer[i][j] == '\n':
                            break
                        else:
                            continue
                alphabet.update({char:[origins, font_x, font_y]})
                line_buffer = []
            else:
                line_buffer.append(l)


def map_word_origins(string_name, string_origins, origin):
    total_gap = 0
    for i in range(string_name.__len__()):
        if i > 0:
            total_gap += alphabet[string_name[i-1]][1] + 1
        string_origins.append((origin[0], origin[1] + total_gap))


def write_char(memory_map, char_coord, origin, color):
    for coord in char_coord:
        memory_map[origin[0]+coord[0]][origin[1]+coord[1]] = color

def write_word(name, origins, alphabet):
    i = 0
    for char in name:
        color = None
        if "*water" in name and char == "*":
            color = BLUE
        elif "defeat" in name:
            color = RED
        else:
            color = GREEN
        write_char(memory_map, alphabet[char][0], origins[i], color=color)
        i += 1

def populate_list(filename, player_list):
    with open(filename, "r") as p:
        p_map = p.readlines()
        for l in p_map:
            keys = l.strip().split(' ')
            for k in keys:
                player_list.append(k)


def populate_map(memory_map, player_list, player_origin):
    for i in range(100):
        line = player_origin[0]
        col = player_origin[1] + i
        # print("{}, {}".format(line, col))
        # print("addr = {}".format((line*128)+col))
        if player_list[i] == WATER:
            memory_map[line][col] = WATER_BODY
        elif player_list[i] == CENTER:
            memory_map[line][col] = SHIP_BODY
        else:
            print("Character undefined.")
            exit(1)

        # line = int(5*(i//10)) + player_origin[1]
        # col = int(5*(i%10)) + player_origin[0]
        # coord = (line, col)
        # write_char(memory_map, alphabet[CENTER], coord, BLUE)
        # if player_list[i] == WATER:
        #     write_char(memory_map, alphabet[CENTER], (line, col), BLUE)
        # elif player_list[i] == CENTER:
        #     write_char(memory_map, alphabet[CENTER], coord, RED)
        # elif player_list[i] == LEFT:
        #     write_char(memory_map, alphabet[LEFT], coord, RED)
        # elif player_list[i] == RIGHT:
        #     write_char(memory_map, alphabet[RIGHT], coord, RED)
        # elif player_list[i] == UPPER:
        #     write_char(memory_map, alphabet[UPPER], coord, RED)
        # elif player_list[i] == LOWER:
        #     write_char(memory_map, alphabet[LOWER], coord, RED)
        # elif player_list[i] == SINGLE:
        #     write_char(memory_map, alphabet[SINGLE], coord, RED)
        # else:
        #     print("Invalid char: {}".format(player_list[i]))
        #     exit(1)

if __name__ == "__main__":
    alphabet = {}
    gen_alphabet(alphabet)

    for i in range(2):
        with open(filenames[i], "w") as f:
            f.write("WIDTH={};\n".format(word_size))
            f.write("DEPTH=\"{}\";\n\n".format(2**bits_addr))
            f.write("ADDRESS_RADIX=UNS;\n")
            f.write("DATA_RADIX=BIN;\n\n")
            f.write("CONTENT BEGIN\n")

            player1_list = []
            player2_list = []

            populate_list("player1.txt", player1_list)
            populate_list("player2.txt", player2_list)

            print(i)
            print((i+1)%2)

            player1_origin = (i, 0)
            player2_origin = ((i+1)%2, 0)

            memory_map = [[BLACK for _ in range(max_col)] for _ in range(max_line)]

            populate_map(memory_map, player1_list, player1_origin)
            populate_map(memory_map, player2_list, player2_origin)

            # # Origin for battleship is (8,34) in VGA display.
            # title = "baTTLeshIP"
            # title_origins = []
            # map_word_origins(title, title_origins, (8, 34))
            # write_word(title, title_origins, alphabet)

            title = "VICTORY"
            title_origins = []
            map_word_origins(title, title_origins, (2, 46))
            write_word(title, title_origins, alphabet)

            title = "defeat"
            title_origins = []
            map_word_origins(title, title_origins, (7, 46))
            write_word(title, title_origins, alphabet)

            for l in range(max_line):
                for c in range(max_col):
                    if memory_map[l][c] == "00000000":
                        print(" ", end="")
                    else:
                        print("X", end="")
                print("")

            for l in range(max_line):
                for c in range(max_col):
                    f.write("   {} : {};\n".format((l*128) + c, memory_map[l][c]))
            f.write("END;\n")




        #Origin for hit is (75, 10)
        #Origin for water is (81, 10)
        # legend1 = "*hit"
        # legend2 = "*water"
        # legend1_origins = []
        # legend2_origins = []
        # map_word_origins(legend1, legend1_origins, (7, 10))
        # write_word(legend1, legend1_origins, alphabet)
        # map_word_origins(legend2, legend2_origins, (13, 10))
        # write_word(legend2, legend2_origins, alphabet)
