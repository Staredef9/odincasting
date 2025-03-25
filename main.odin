package odincasting

import "core:fmt"
import sdl "vendor:sdl2"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080

FPS :: 30 
FRAME_TIME_LENGTH :: 1000/ FPS



isGameRunning := true
ticksLastFrame : u32 = 0
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

setup :: proc() {
    // Initialize game elements
}

processInput :: proc() {
    event: sdl.Event
    for sdl.PollEvent(&event) {
        #partial switch event.type {
            case .QUIT:
                isGameRunning = false
            case .KEYDOWN:
                if event.key.keysym.sym == sdl.Keycode.ESCAPE {
                    isGameRunning = false
                }
        }
    }
}

update :: proc() {
    /*
    for !sdl.TICKS_PASSED(sdl.GetTicks(), ticksLastFrame + FRAME_TIME_LENGTH){
        
    }*/

    timeToWait : u32 = FRAME_TIME_LENGTH - (sdl.GetTicks() - ticksLastFrame)
    if timeToWait > 0 && timeToWait <= FRAME_TIME_LENGTH{
    sdl.Delay(timeToWait)
}

    deltaTime : f32 = f32(sdl.GetTicks() - ticksLastFrame) / 1000.0
    ticksLastFrame = sdl.GetTicks()

    playerX += 100 * deltaTime
    playerY += 100 * deltaTime
}

render :: proc() {
    sdl.SetRenderDrawColor(renderer, 0, 125, 125, 255)
    sdl.RenderClear(renderer)
    
    // Render game elements
    sdl.SetRenderDrawColor(renderer, 255, 0, 0, 255) // Red color for rectangle
    rect: sdl.Rect = {i32(playerX), i32(playerY), 50, 50}
    sdl.RenderFillRect(renderer, &rect)
    
    sdl.RenderPresent(renderer)
}

main :: proc() {
   
    window: ^sdl.Window
    isGameRunning = initWindow(&window)
    
    if isGameRunning {
        setup()
        
        for isGameRunning {
            processInput()
            update()
            render()
        }
    }
    
    destroyWindow(&window)
}