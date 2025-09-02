# Thumb-2 Implementation Work of Memory/Time-Related C Standard Library Functions

## Overview
A implementation of several functions of the C standard library using the Thumb-2 assembly language. The assembly language utilizes the Keil MDK ARM software development
environment, emulating in the ARM Cortex microcontroller on the Texas Instrucment TM4C series target device (TM4C1233H6PM).

## System Requirments
* Keil MDK-ARM (µVision IDE)
* Device Family Pack (DFP) for TM4C
* Windows OS 7 or higher (32-bit or 64-bit).

## Installation/Running Services

** Installation
1. Install Keil using the following link: https://www.keil.com/download/

   a. Choose "Product Downloads" and "MDK-ARM", and submit a request to download MDK536.EXE
   
   b. After installation, install the TM4C pack from Pack Installer app.

3. Download repositry zip and open ARM_Final Keil driver file
   
   a. Download repositry zip
   
   b. Extract all
   
   c. Navigate and open ARM_Final Keil driver file (master->src->ARM_Final)

5. Inside Keil, before starting a debugging simulation turn on the debug simulator
   
   a. Right click Target_1 and choose "Options for Target"
   
   b. In the menu click the "Debug" menu and "Use Simulator" checkbox
   
