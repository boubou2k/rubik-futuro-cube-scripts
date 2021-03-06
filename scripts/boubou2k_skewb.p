/*
boubou2k_skewb.p

This is a skewb implementation.

Tap to shuffle.
Put a corner to the top and tap on the cube to rotate it.
The goal is to put each color on its own side, like rubik's cube.
*/

#include <futurocube>

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,0,
    cORANGE,cORANGE,cPURPLE,
    cORANGE,cPURPLE,cPURPLE,
    cPURPLE,cPURPLE,cPURPLE,
    '''','''']
new palette[]=[
    cORANGE, cPURPLE, cRED, cBLUE, cGREEN, cMAGENTA
    ]

new savedgame[] = [VAR_MAGIC1, VAR_MAGIC2, ''boubou2k_skewb'']

new const corners[8][27] = [[
        42, 20, 0,
        43, 39, 19, 23, 3, 1,
        44, 40, 36, 18, 22, 26, 6, 4, 2,
        41, 37, 11, 21, 25, 45, 7, 5, 27
    ], [
        27, 44, 2,
        30, 28, 41, 43, 1, 5,
        33, 31, 29, 38, 40, 42, 0, 4, 8,
        37, 39, 20, 3, 7, 47, 34, 32, 9
    ], [
        47, 33, 8,
        46, 50, 34, 30, 5, 7,
        45, 49, 53, 35, 31, 27, 2, 4, 6,
        48, 52, 15, 32, 28, 44, 1, 3, 26
    ], [
        26, 45, 6,
        23, 25, 48, 46, 7, 3,
        20, 22, 24, 51, 49, 47, 8, 4, 0,
        19, 21, 17, 52, 50, 33, 5, 1, 42
    ], [
        38, 29, 9,
        37, 41, 28, 32, 12, 10,
        36, 40, 44, 27, 31, 35, 15, 13, 11,
        39, 43, 2, 30, 34, 53, 16, 14, 18
    ], [
        18, 36, 11,
        21, 19, 39, 37, 10, 14,
        24, 22, 20, 42, 40, 38, 9, 13, 17,
        25, 23, 0, 43, 41, 29, 12, 16, 51
    ], [
        51, 24, 17,
        52, 48, 25, 21, 14, 16,
        53, 49, 45, 26, 22, 18, 11, 13, 15,
        50, 46, 6, 23, 19, 36, 10, 12, 35
    ], [
        35, 53, 15,
        32, 34, 50, 52, 16, 12,
        29, 31, 33, 47, 49, 51, 17, 13, 9,
        28, 30, 8, 46, 48, 24, 14, 10, 38
    ]]

new const ANIM_DELAY = 72

new cube[54]

/* Initialize game */
init() {
    ICON(icon)
    SetIntensity(256)
    RegisterVariable(savedgame)
    RegAllSideTaps()
    PaletteFromArray(palette)
}

/* Intro animation */
intro() {
    new i
    for (i=0; i<6*9; i++)
        cube[i] = i/9+1
    refresh()
}

loadgame() {
    if(IsGameResetRequest() || !LoadVariable(''boubou2k_skewb'', cube)) {
        return 0
    } else {
        refresh()
        return 1
    }
}
savegame() {
    StoreVariable(''boubou2k_skewb'', cube)
}

/* Wait for tab before start */
tapToStart() {
    new motion = 0

    Play("_g_TAPFORSHUFFLE")
    for (;;) {
        Sleep()
        motion=Motion()
        if (motion) {
            AckMotion()
            break
        }
    }
    Play("kap")
    Delay(100)
}

generate() {
    new i
    for (i=0; i<6*9; i++) {
        cube[i] = i/9+1
    }
    refresh()
}

shuffle() {
    new i, corner

    Play("_g_SHUFFLING")
    generate()

    for (i=0; i<200; i++) {
        corner = GetRnd(8)
        rotate(corner, 1)
    }

    Quiet()
}

rotate(corner, delay=0) {
    rotate30(corner, 1, 0)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(corner, 1, 1)
    refresh()
    Sleep(delay>0?delay:ANIM_DELAY)

    rotate30(corner, 0, 0)
    refresh()
}
rotate30(corner, layer1=0, layer2=0) {
    new i, temp1, temp2

    temp1 = cube[corners[corner][9]]
    temp2 = cube[corners[corner][18]]
    for (i=10; i<18; i++) {
        cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][i-1+9]] = cube[corners[corner][i+9]]
    }
    cube[corners[corner][17]] = temp1
    cube[corners[corner][26]] = temp2

    if (layer1) {
        temp1 = cube[corners[corner][3]]
        for (i=4; i<9; i++)
            cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][8]] = temp1
    }

    if (layer2) {
        temp1 = cube[corners[corner][0]]
        for (i=1; i<3; i++)
            cube[corners[corner][i-1]] = cube[corners[corner][i]]
        cube[corners[corner][2]] = temp1
    }
}

refresh() {
    ClearCanvas()
    DrawArray(cube)
    PrintCanvas()
}

findCorner(cursor) {
    new i, idx = _i(cursor)
    for (i=0; i<8; i++)
        if (idx == corners[i][0] || idx == corners[i][1] || idx == corners[i][2])
            return i
    return -1
}

highlightCorner(corner) {
    new i
    if (corner >= 0) {
        ClearCanvas()
        DrawArray(cube)
        for (i=0; i<27; i++) {
            SetColor(cube[corners[corner][i]])
            DrawFlicker(corners[corner][i], 20, FLICK_STD, 0)
        }
        PrintCanvas()
    } else {
        ClearCanvas()
        DrawArray(cube)
        PrintCanvas()
    }
}

success() {
    Play("clapping")
    Delay(2000)
}

checkSuccess() {
    new i
    for (i=0; i<54; i++)
        if (cube[i] != cube[i-i%9])
            return 0
    return 1
}

main() {
    init()
    if (!loadgame()) {
        intro()
        tapToStart()
        shuffle()
    }

    new corner

    for (;;) {
        Sleep()

        corner = findCorner(GetCursor())
        highlightCorner(corner)

        if (Motion()) {
            if (eTapSideOK() && corner >= 0) {
                Vibrate(50)
                rotate(corner)
                savegame()
            }
            AckMotion()
        }

        if (checkSuccess()) {
            success()
            tapToStart()
            shuffle()
        }
    }
}
