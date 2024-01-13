#### LEARNING GOALS
- Learn some important concepts
    - Process
    - Scheduling
    - Memory
    - Page
    - Concurrency
    - Loch
    - Semaphore
    - I/O Devices
    - File systems
 
## WHAT IS AN OPERATING SYSTEM?
```
#include <stdio.h>

int main(){
  printf("Hello World!\n");
  return 0;
}
```
To execute the program above:
1. Compile the program: gcc hello.c -o hello. This will generate the executable named hello
2. Execute the program: ./hello. This will print out "Hello World!"
3. Executing two executables: ./hello & ./hello. Is this possible? Returns
```
   [1] 6696
   Hello World!
   Hello World!
   [1] + done ./hello
```
>Why?
   
These are questions we will answer in this course;
- How is the executable _hello_ stored on the computer?
- How does the computer locate the _hello_ on the file system?
- What hardware does _hello_ use for its execution?
- Which _hello_ is executed first?


>__DEF:__ An operating system is a program that manages a computer`s hardware. It also provides a basis for application programs and acts as an intermediary between the computer user and the computer hardware.

```
Services and management <-> Management and abstract
System and application programs - OS - Hardware
```

## WHAT DOES OS PROVIDE?

#### Abstraction - Provide a standard library for resources
- What is a __resource__?
  - Anything valuable on your computer(e.g. screen, mouse, CPU, memory, disk)
- What abstraction does modern OS typically provide for each resource?
  - CPU: process and/or thread
  - Memory: address space
  - Disk: files
- Advantages of OS providing abstraction
  - Separate interface and underlying hardware implementation
  - Allow applications to reuse common facilities
  - Make different devices look the same


#### Resource management - Share resources in a good manner
- Advantages of OS providing resource management
  - Protect applications from one another
  - Provide efficient access to resources (cost, time, energy)
  - Provide fair access to resources. No need for programs to compete
- Policies
  - What to do?
  E.g. scheduling algorithms, etc.
- Mechanisms
  - How to do?
  - A scheduling algorithm is designed and implemented in a specific way
 
  ## OS STRUCTURE
  - OSs are becoming more complicated as more functionalities are added
  - To manage the increasing complexity, some techniques can be deployed:
    - Modularity
    - Abstraction
    - Layering
    - Hierarchy
  - Complex OSs are divided into several layers ()
  - Kernel is the core of an OS
  - It is the software responsible for providing secure access to the hardware and executing programs
    - Process management
    - Device driver
    - Memory management
    - System calls
   
  #### System Calls
  - System calls provide the interface between a running program and the operating system kernel
    - Generally available in routines written in C and C++
    - Certain low-level tasks may have to be written using assembly language
   
    <img src="https://1480285644-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-M13JlZNu0b_edmxHTQk%2F-M4bi4LFDWarrQTldkn5%2F-M4bienH9ewqFuJ1nrOo%2Fimage.png?alt=media&token=3e730071-271e-4783-a57d-c5eb5011f97b" width="500px">

  - The run-time support system (run-time libraries) provides a system-call interface,
    - A number associated with each system call
    - System-call interface maintains a table indexed according to these numbers
  - Major differences in how they are implemented (e.g. Windows vs. Unix)
    <img src="https://i.stack.imgur.com/tLg6b.png" width="500px">

#### Simple structure
- Programs and OS have the same level of privilege
- Pros: Efficiency, no switch
- Cons No isolation, security issue
- E.g. MS-DOS, only terminal commenting
  - User space: Nothing
  - Kernel Space: APP and OS

#### Monolithic Kernel
- The entire OS works in the kernel space
- Pros: Good isolation, security
- Cons: Reliability, inflexibility
- E.g. Linux, Unix
  - User space: APP - Applications
  - Kernel Space: OS - System calls, File system, device drivers, IPC, scheduler, Virtual Memory
  
#### Microkernel
- Some services or modules are decoupled from the OS kernel and stay in user space
- Pros: Reliability, security, flexibility
- Cons: Complexity, communication overhead
- E.g. Mach, Blackberry, QNX, L4
  - User space: APP & Services - Applications & Device drivers, Application IPC
  - Kernel Space: OS - File system, system calls, Basic IPC, scheduler, Virtual Memory

#### Hybrid kernel
- Combines monolithic and microkernel
- A trade-off between the two categories
- Inherits pros and cons from both
- E.g. Windows, Apple OSs
  - User space: APP & Services - Applications & File server
  - Kernel Space: OS - Device drivers, IPC, File system, system calls, Basic IPC, scheduler, Virtual Memory
 
## GOALS OF OS
- Primary goals of OS
  - Use the computer hardware in an efficient manner
  - Execute user programs and make solving user problems easier
  - Make the computer system convenient to use
- To achieve these goals involves three pieces
  - Virtualization: Abstracting underlying hardware, e.g. CPU, memory, or disk
  - Concurrency: Events are occurring simultaneously and may interact with one another
  - Persistence: Safely storing data on different storage devices, e.g. hard drive, solid
- Other goals:
  - Protection
      - Between applications, between OS and applications
      - Isolation: Prevent bad processes to harm others
  - Reliability
      - OS plays a fundamental role for applications` execution
      - OS runs non-stop
  - Energy-efficiency
      - Sustainability
      - Battery-supplied
  - Security
      - More sensitive and private data
  - Mobility
      - IoT devices and embedded devices










