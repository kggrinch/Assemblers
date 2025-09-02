# Thumb-2 Implementation Work of Memory/Time-Related C Standard Library Functions

## Overview
An implementation of several functions of the C standard library using the Thumb-2 assembly language. The assembly language utilizes the Keil MDK ARM software development
environment, emulating in the ARM Cortex microcontroller on the Texas Instrument TM4C series with the target device (TM4C1233H6PM).

## System Requirments
* Keil MDK-ARM (µVision IDE)
* Device Family Pack (DFP) for TM4C
* Windows OS 7 or higher (32-bit or 64-bit)

## Installation/Running Services

=== Installation ===
1. Install Keil using the following link: https://www.keil.com/download/

   a. Choose "Product Downloads" and "MDK-ARM", and submit a request to download MDK536.EXE
   
   b. After installation, install the TM4C pack from the Pack Installer app

3. Download the repository zip and open the ARM_Final Keil driver file.
   
   a. Download repository zip
   
   b. Extract all
   
   c. Navigate and open the ARM_Final Keil driver file (master->src->ARM_Final)

5.  Inside Keil, before starting a debugging simulation, turn on the debug simulator.
   
   a. Right-click Target_1 and choose "Options for Target"
   
   b. In the menu, click the “Debug” menu and “Use Simulator” checkbox.
   
=== Running Service ===
1. Once the project is set up, to build an executable, choose “Project” and “Build Target.” If there are no error messages, the compilation was a success.
2. For tracing code using a debugger, set breakpoints and select “Debug” and “Start/Stop Debugging Session".
3. To restart the project inside the debugger, simply click “Reset the CPU”.
4. To stop the debugging mode, choose “Debug” and “Start/Stop Debugging Session".

## Project Structure & Memory Explnation 

=== Project Structure ===

src Folder
* src folder contains all source material to build, execute, and run the ARM Final service.
* For an in-depth explanation of individual files and their purpose with function details, please refer to Final_Project_READ_ME.pdf located at master->additional_files->Final_Project_READ_ME

additional_files
* additional_files folder contains all details of project implementation, which includes documentation of all files within the src folder, diagrams, and screenshots of important functionality.

c_reference_files
* c_reference_files folder includes the C adaptation of the C standard library that was used as a reference while implementing functions in the Thumb-2 assembly language.

=== Important Memory Addresses ===

* (_strncpy & _bzero) - To view the strncpy and bzero in debugging, use the [0x20005814] memory address.
* (_malloc & _free) - To view the MCB memory in action of the _malloc and _free, use the [0x20006800] memory address.
* (_malloc & _free & *alarmed) - To view the heap memory during heap manipulation of the alarm pointer, use the [0x20001000] memory address.
* (_signal & _alarm) - To view the _signal functional call and _alarm in action, use the [0x20007B80] memory address.


## Contact Information

Team Assemblers - CSS422 Spring 2025

* Kirill Grichanichenko | Email: kggrinch@gmail.com
* Artem Grichancichenko | Email: ArtemG8@uw.edu

CSS422 Hardware And Computer Organization: University of Washington Bothell
