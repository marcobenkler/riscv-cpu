## Block
Goal: Verify each subsystem seperated, no matter how it's used in the CPU  
Example: ALU, CLINT or UART  

## Core
Goal: Functional correctnes from the viewpoint of the program  
Example: If instruction x ist executed, is the architecture state correct (reg x1 contains 0xA425, ...)  

## Pipeline
Goal: Verify the correct computation over multiple clocks  
Example: Interrupt every second clock for 1k clocks  

## System
Goal: Make sure the integration works  
EXAMPLE: CPU triggers interrupt, when UART wants to write  

## Global
Goal: Verify crossattributes and performance  
Example: Reset when srt is dividing and pipeline is stalling  