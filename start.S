.equ PORTC_ODR,		0x4001100C	@ .equ is like #define
.equ GPIOC_CHR, 	0x40011004	@ These numbers are adresses of
.equ RCC_APB2ENR, 	0x40021018	@ registers, that we will need

.equ LOOP_COMPARE, 	0xfffff		@ How much times should wait: be called
								@ before changing the LED state?

.equ STACKINIT, 0x20005000

.cpu cortex-m3
.syntax unified

.thumb_func
.global _start
_start:
    stacktop: .word 0x20001000
    .word reset

    
    
.thumb_func
.global reset
reset:
    @ Enable Clock for GPIOC
    ldr r1, =(1 << 4)       @ load to r1 value we want to write to RCC_APB2ENR
    ldr r2, =#RCC_APB2ENR   @ load to r2 RCC_APB2ENR address
    str r1, [r2]            @ store (1 << 4) in RCC_APB2ENR
    
    @ Set C13 to output
    ldr r1, =(0b11 << 20)
    ldr r2, =#GPIOC_CHR
    str r1, [r2]
    
    @ let's wait a bit
	@	r0 -> counter
	@	r4 -> will be comparing with it
	@	r5 -> led state
	
	ldr r0, =0				@ initialize counter
	ldr r4, =#LOOP_COMPARE	@ load #LOOP_COMPARE to r4
	ldr r5, =0				@ initialize led_state

   
wait:
    add r0, r0, #1			@ add 1 to r0
    cmp r0, r4				@ compare with #LOOP_COMPARE
    
    it lt
    blt wait				@ if r0 < r4 (#LOOP_COMPARE), go back to wait
    
    @ if we're done waiting, let's decide if we should down or up led
    ldr r0, =0				@ set counter back to 0
    
    cmp r5, #1				@ check if led_state == 1
    
    itt eq					@ if state == 1, let's change it to 0 and jump to led_up
    ldreq r5, =0
    beq	led_up
    
    ldr r5, =1				@ if state != 1 so state == 0, let's do the opposite
    b	led_down
    

    
led_down:
    @ Set PC13 HIGH, so turn the LED off
    ldr r1, =(1 << 13) 		  @ load to r1 the value we want to write to PORTC_ODR
    ldr r2, =#PORTC_ODR       @ load to r2 PORTC_ODR adress
    str r1, [r2]              @ store!
    
    b wait					  @ call wait again
    
led_up:
	@ Set PC13 LOW, so turn the LED on
	ldr r1, =0
	ldr r2, =#PORTC_ODR
	str r1, [r2]
	
	b wait

    
    
    
