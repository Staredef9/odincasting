package odincasting

import "core:fmt"
import sdl "vendor:sdl2"
import "core:math"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080

FPS :: 30 
FRAME_TIME_LENGTH :: 1000/ FPS

PI :: 3.14159265
TWO_PI :: 6.28318530

TILE_SIZE :: 64
MAP_NUM_ROWS :: 13
MAP_NUM_COLS :: 20 

WINDOW_WIDTH :: MAP_NUM_COLS * TILE_SIZE
WINDOW_HEIGHT :: MAP_NUM_ROWS * TILE_SIZE

MINIMAP_SCALE_FACTOR :: 0.5
PLAYER_SCALE_FACTOR :: 5

FOV_ANGLE :: 60 * (PI / 180)

NUM_RAYS :: WINDOW_WIDTH 
//per ora hard coded
//TODO: una library per ingestare mappe al volo e cambiare i livelli 
//TODO 2 : un editor di livelli e mappe interno all'engine
game_map ::  [MAP_NUM_ROWS][MAP_NUM_COLS]i32 {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ,1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
}

isGameRunning := true
ticksLastFrame : u32 = 0



player :: struct {
    x : f32,
    y : f32,
    width : f32,
    height : f32,
    rotationAngle :f32,
    walkSpeed : f32,
    turnSpeed : f32,
    turnDirection : i32,
    walkDirection : i32,
}



playerX: f32 = 0
playerY: f32 = 0

// Global variables for window and renderer
renderer: ^sdl.Renderer

initWindow :: proc(window: ^^sdl.Window) -> bool {
    if sdl.Init(sdl.INIT_EVERYTHING) != 0 {
        fmt.printfln("Could not init sdl2: %v\n", sdl.GetError())
        return false
    }
    
    window^ = sdl.CreateWindow("myWindow",
                        sdl.WINDOWPOS_CENTERED, 
                        sdl.WINDOWPOS_CENTERED,
                        SCREEN_WIDTH,
                        SCREEN_HEIGHT, 
                        sdl.WINDOW_RESIZABLE)
    
    if window == nil {
        fmt.printfln("Could not create window: %v\n", sdl.GetError())
        return false
    }
    
    renderer = sdl.CreateRenderer(window^, -1, {})
    
    if renderer == nil {
        fmt.printfln("Could not create renderer: %v\n", sdl.GetError())
        sdl.DestroyWindow(window^)
        return false
    }
    
    sdl.SetRenderDrawBlendMode(renderer, sdl.BlendMode.BLEND)
    return true
}

destroyWindow :: proc(window: ^^sdl.Window) {
    if renderer != nil {
        sdl.DestroyRenderer(renderer)
    }
    if window != nil {
        sdl.DestroyWindow(window^)
    }
    sdl.Quit()
}

setup :: proc(my_player : ^player) {
    // Initialize game elements

    //inizializza il player 
    my_player.x = WINDOW_WIDTH / 2
    my_player.y = WINDOW_HEIGHT / 2
    my_player.height = 5
    my_player.width =  5
    my_player.turnDirection = 0
    my_player.walkDirection = 0
    my_player.rotationAngle = PI / 2
    my_player.walkSpeed = 100
    my_player.turnSpeed = 45 * (PI / 180)

}

processInput :: proc(my_player : ^player) {
    event: sdl.Event
    for sdl.PollEvent(&event) {
        #partial switch event.type {
            case .QUIT:
                isGameRunning = false
            
                
        //NON FUN
                //by reference per modificare posizione
            case .KEYDOWN:
                #partial switch event.key.keysym.scancode{
                    
                    case sdl.SCANCODE_UP:
                        my_player.walkDirection += 1    
                    case sdl.SCANCODE_DOWN:
                        my_player.walkDirection -= 1
                    case sdl.SCANCODE_LEFT:
                        my_player.turnDirection -= 1
                    case sdl.SCANCODE_RIGHT:
                        my_player.turnDirection += 1
                }
            
            case .KEYUP:
                #partial switch event.key.keysym.scancode{
                    case sdl.SCANCODE_UP, sdl.SCANCODE_DOWN:
                        my_player.walkDirection = 0
                    case sdl.SCANCODE_LEFT, sdl.SCANCODE_RIGHT:
                        my_player.turnDirection = 0
                }


        }
    }
}


movePlayer :: proc(deltaTime : f32, my_player : ^player){
    //TODO Aggiorna movimento player 
    //fai bound checking con mappa
    //fai bound checking con i muri
    //ruota per bene e fa si che segua la linea correttamente 
 //TODO fai cose con il player
     my_player.rotationAngle += f32(my_player.turnDirection) * my_player.turnSpeed * deltaTime
     moveStep := f32(my_player.walkDirection) * my_player.walkSpeed

     newPlayerX := my_player.x + math.cos(my_player.rotationAngle) * moveStep * deltaTime
     newPlayerY := my_player.y + math.sin(my_player.rotationAngle) * moveStep * deltaTime

     my_player.x = newPlayerX
     my_player.y = newPlayerY
}


update :: proc(my_player: ^player) {
    /*
    for !sdl.TICKS_PASSED(sdl.GetTicks(), ticksLastFrame + FRAME_TIME_LENGTH){
        
    }*/

    timeToWait : u32 = FRAME_TIME_LENGTH - (sdl.GetTicks() - ticksLastFrame)
    if timeToWait > 0 && timeToWait <= FRAME_TIME_LENGTH{
    sdl.Delay(timeToWait)
    }

    deltaTime : f32 = f32(sdl.GetTicks() - ticksLastFrame) / 1000.0
    ticksLastFrame = sdl.GetTicks()


    //MA questo serve davvero se c'e' process input ???
    movePlayer(deltaTime, my_player)



    //playerX += 100 * deltaTime
    //playerY += 100 * deltaTime
}



renderPlayer :: proc (my_player : ^player){

    sdl.SetRenderDrawColor(renderer, 255, 255, 255, 255)

   playerRect := sdl.Rect {
    i32(my_player.x  * MINIMAP_SCALE_FACTOR),
    i32(my_player.y * MINIMAP_SCALE_FACTOR),
    i32(my_player.width * PLAYER_SCALE_FACTOR),
    i32(my_player.height * PLAYER_SCALE_FACTOR)
   } 

   sdl.RenderFillRect(renderer, &playerRect)


   sdl.RenderDrawLine(renderer, 
    i32(my_player.x * MINIMAP_SCALE_FACTOR), 
    i32(my_player.y * MINIMAP_SCALE_FACTOR), 
    i32((my_player.x * MINIMAP_SCALE_FACTOR + (math.cos(my_player.rotationAngle) * 40 ) )), 
    i32((my_player.y * MINIMAP_SCALE_FACTOR+ (math.sin(my_player.rotationAngle) * 40) )))

}



renderMap :: proc(){
  var_game_map := game_map

    for i in 0..<MAP_NUM_ROWS {
        for j in 0..<MAP_NUM_COLS{
    
            tileX := j * TILE_SIZE
            tileY := i * TILE_SIZE
            tileColor := var_game_map[i][j] != 0 ? 255 : 0
            sdl.SetRenderDrawColor(renderer, u8(tileColor), u8(tileColor), u8(tileColor), 255)
           // mapTileRect : sdl.Rect = sdl.Rect{ math.round(f32(tileX * MINIMAP_SCALE_FACTOR)), math.round(f32(tileY * MINIMAP_SCALE_FACTOR)),, TILE_SIZE * MINIMAP_SCALE_FACTOR, TILE_SIZE * MINIMAP_SCALE_FACTOR} 
            mapTileRect := sdl.Rect{
                i32(math.round(f32(tileX) * MINIMAP_SCALE_FACTOR)),
                 i32(math.round(f32(tileY) * MINIMAP_SCALE_FACTOR)),
                i32(math.round(f32(TILE_SIZE) * MINIMAP_SCALE_FACTOR)),
                 i32(math.round(f32(TILE_SIZE) * MINIMAP_SCALE_FACTOR)),
            } 
    
            
            sdl.RenderFillRect(renderer, &mapTileRect)
    
    
    
    
    
        }
    }
    
}



render :: proc(my_player : ^player) {
    //questo e' lo sfondo 
    sdl.SetRenderDrawColor(renderer, 0, 125, 125, 255)
    sdl.RenderClear(renderer)
    
    // Render game elements
   // sdl.SetRenderDrawColor(renderer, 255, 0, 0, 255) // Red color for rectangle
   // rect: sdl.Rect = {i32(playerX), i32(playerY), 50, 50}
   // sdl.RenderFillRect(renderer, &rect)

    renderMap()
    renderPlayer(my_player)
    sdl.RenderPresent(renderer)
}

main :: proc() {
  
    my_player : player
    window: ^sdl.Window
    isGameRunning = initWindow(&window)
    
    setup(&my_player)

    var_game_map := game_map

    for i in 0..<MAP_NUM_ROWS {
        for j in 0..<MAP_NUM_COLS{
            fmt.printf("%d", var_game_map[i][j])
        }
            fmt.printf("\n")
    }
     
    if isGameRunning {
        
        for isGameRunning {
            processInput(&my_player)
            update(&my_player)
            render(&my_player)
        }
    }
    
    destroyWindow(&window)
    return 
}