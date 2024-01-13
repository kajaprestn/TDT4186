### LEARNING GOALS

We'll explore key concepts in operating systems:

- **Process:** A program in execution. Think of it as an active entity, not just the code.
- **Scheduling:** How the OS decides which process runs at what time.
- **Memory:** Where your computer stores data. In OS, it's about managing this space.
- **Page:** A way of managing memory in chunks.
- **Concurrency:** Doing multiple things at the same time.
- **Lock:** A tool to ensure that only one process uses a resource at a time.
- **Semaphore:** Like a more flexible lock for controlling access to resources.
- **I/O Devices:** Input/Output devices like keyboards, mice, and printers.
- **File Systems:** How files are organized and stored.

## WHAT IS AN OPERATING SYSTEM?

Consider a simple C program:

```c
#include <stdio.h>

int main(){
  printf("Hello World!\n");
  return 0;
}
```

To run this program:
1. Compile: `gcc hello.c -o hello` - This creates an executable.
2. Execute: `./hello` - This prints "Hello World!"
3. Run two instances: `./hello & ./hello` - Both run simultaneously.

*Why can you run two at the same time?* That's part of what we'll explore.

Questions we'll answer:
- How is _hello_ stored and found on the computer?
- What hardware does _hello_ use?
- Which instance of _hello_ executes first?

> __DEF:__ An operating system is a program that manages computer hardware. It acts as a mediator between users and the computer's hardware.

Diagram:
```
Services and management <-> Management and abstract
System and application programs - OS - Hardware
```

## WHAT DOES OS PROVIDE?

#### Abstraction - Standardizing access to resources

- **Resource:** Anything valuable in your computer, like the CPU or memory.
- **OS Abstraction Examples:**
  - **CPU:** Seen as processes or threads.
  - **Memory:** Managed as an address space.
  - **Disk:** Organized into files.
- **Advantages:**
  - Separates interface from hardware.
  - Allows reuse of common facilities.
  - Makes diverse devices work similarly.

#### Resource Management - Efficient and fair sharing

- **Advantages:**
  - Protects applications from each other.
  - Ensures efficient and fair access to resources.
- **Policies and Mechanisms:**
  - **Policies:** Define what to do, like scheduling algorithms.
  - **Mechanisms:** Define how to do it, implementing policies in specific ways.

## OS STRUCTURE

OS complexity is growing. To manage this, OSs use:
- Modularity
- Abstraction
- Layering
- Hierarchy

OSs are divided into layers. The core is the **Kernel**, handling secure hardware access and program execution. This includes process management, memory management, system calls, and more.

#### System Calls

- Interface between programs and the OS kernel.
- Usually in C/C++, sometimes assembly for low-level tasks.
- System-call interface uses a table indexed by numbers for each call.
- Implementation varies (e.g., Windows vs. Unix).

![System Call Example](https://i.stack.imgur.com/tLg6b.png)

#### OS Structures

- **Simple Structure:**
  - No distinction between OS and programs.
  - **Example OS:** MS-DOS (Microsoft Disk Operating System).
  - **Pros:** Efficient in terms of performance because there's minimal switching between different modes.
  - **Cons:** High security risks as applications can directly interact with hardware and other applications, leading to potential system crashes or security breaches.

- **Monolithic Kernel:**
  - Entire OS in kernel space.
  - **Example OSs:** 
    - Linux: Known for its use in servers and desktops.
    - UNIX: The precursor to many modern operating systems, including Linux.
  - **Pros:** Offers good isolation and security as the kernel has complete control over system resources.
  - **Cons:** Can be less flexible because any changes or updates to the system may require modifying the kernel.

- **Microkernel:**
  - Decouples some modules, keeping them in user space.
  - **Example OSs:** 
    - Minix: Designed for educational purposes, demonstrating microkernel architecture.
    - QNX: Used in various embedded systems.
  - **Pros:** More reliable and secure as essential parts of the OS are isolated from system crashes and bugs in other components.
  - **Cons:** Can be more complex to develop and may suffer from performance overhead due to more inter-process communication.

- **Hybrid Kernel:**
  - Mix of monolithic and microkernel.
  - **Example OSs:**
    - Windows NT (and subsequent versions like Windows 10): Combines aspects of both monolithic and microkernel designs.
    - Apple's macOS: Derives from both monolithic (UNIX) and microkernel (Mach) architectures.
  - **Pros:** Balances the advantages of both monolithic and microkernel designs, offering better performance than pure microkernels and more flexibility and modularity than monolithic kernels.
  - **Cons:** Can inherit some of the disadvantages of both architectures and can be complex in terms of design and maintenance.

## GOALS OF OS

Main Goals:
- Efficient hardware use.
- Ease of solving user problems.
- User convenience.

Three Key Pieces:
- **Virtualization:** Abstracting hardware like CPU or memory.
- **Concurrency:** Managing simultaneous events and interactions.
- **Persistence:** Safe data storage on various devices.

Other Goals:
- Protection and Isolation.
- Reliability.
- Energy Efficiency.
- Security.
- Mobility for IoT and embedded devices.
