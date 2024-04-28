# Learning Objectives

## 1. Operating Systems

- **What are the three OS structures?**

  The three main structures of operating systems are:
  
  - *Monolithic kernel*: Operating system architecture where the entire OS is working in the kernel. This means that the system services operate in a large single process with full access to all of the system's hardware and memory.

  - *Microkernel*: Operating system architecture that keeps the core functionality of the OS minimal and runs most services in separate processes, usually in user space, outside of the kernel. 

  - *Hybrid kernel*: Operating system architecture that blends elements from both monolithic kernels and microkernels. It aims to provide a balance between efficiency and modularity by running som essential services (like device drivers and file management) in the kernel space for faster performance, and less critical services in user space. This structure allows hybrid kernels to be more flexible and secure compared to a strictly monolithic kernel, as it isolated various services to prevent system-wide crashes.


- **What are the pros and cons of each OS structure?**

  The pros and cons of each OS structure is listed below.
  
  - *Monolithic kernel*:
    - Pros: Very fast and efficient since everything necessary to manage the system is in one place and can communicate directly and quickly.
    - Cons: Since everything is so interconnected, it can also mean that if one part fails, it might affect the entire system, leading to potential stability issues. Large kernel space.

  - *Microkernel*:
    - Pros: Stable and secure because if one separate service fails, it doesn't necessarily crash the entire system. Smaller kernel space. 
    - Cons: Since there is more communication between the different parts of the system (as services are more separated), it can be slower compared to a monolithic kernel.

  - *Hybrid kernel*:
    - It inherits the pros and cons from both monolithic kernels and microkernels. 


- **Which OS structure do modern OSs use? E.g., Windows, Linux.**
  - *MS-DOS*: simple structure
  - *Linux*: monolithic kernel
  - *UNIX*: monolithic kernel
  - *Minix*: microkernel
  - *Windows*: hybrid kernel
  - *MacOS*: hybrid kernel


- **What are the design goals for OSs?**
  - Efficiency - efficient use of hardware and energy
  - Reliability - reliable and able to run continuously
  - Scalability - able to perform as the load increases of as it is deployed on more powerful hardware
  - Portability - designed to run on a variey of hardware platforms without significant modifications.
  - Security - protect against unauthorized access to the systems's resources
  - User-friendliness - easy to use
  - Compability - support a wide range of software application and hardware peripherals
  - Modularity - modular, allowing for easier updates and maintenance.


> The **kernel** is the **core** of an OS, handling secure hardware access and program execution.

> **System services**: file system, device drivers, memory management, etc.



## 2. Processes

- **What is a process? What is the main difference between a program and a process?**

  A process is a program in execution. It includes the program code and its current activity. A process also includes the process state, memory allocation, and management information used by the OS to manage the process.  Depending on the OS, a process may contain multiple threads that execute instructions concurrently. A program refers to a set of instructions or code written to perform a spesific task. It is a static entity, meaning it is just the code and data stored on the storage media. A program becomes a process when it is loaded into memory and executed. To conclude; a **program** is passive and contains a set of instructions - it is not executing. A **process** is active, with its instructions being exectued by the system's CPU, and having resources allocated to it like memory and CPU time.


- **What do ```fork()```, ```exec()```, and ```wait()``` do? Given a code snippet with these functions, you should know how to analyze the code and decide what is the output.**

  - ```fork()```: Used to create a new process by duplicating the calling process. The new process is called the child process. This function returns twice: once in the parent process, where it retuns the process ID of the newly created child process, and once in the child process where it retuns 0. If the fork fails, it returns -1 in the parent. Often used when a process needs to perform multiple tasks simulaneously. After forking, both the parent and the child processes wil execute the subsequent code independently.
  - ```exec()```: (Family of functions that) replaces the current process image with a new process image. It loads the binary code of a new program into the current process, effectively overwriting the existing program. This is used when you don't need the original process to continue after starting the new program.
  - ```wait()```: Make the calling process (usually the parent) wait until one of its child processes exits of a signal is received. When a child process stops or terminates, the commant ensures that the system resources used by the child are released (avoiding ZOMBIE processes). Normally used after a ```fork()``` to handle synchronization between parent and child processes, ensuring that a parent process waits for the completion of its child processes. 

```c
int main() {
    pid_t pid = fork();  // The parent process creates a child process using fork().

    if (pid == 0) { // Child process
        execlp("/bin/ls", "ls", "-l", (char *)NULL); // The child process executes execlp(), replacing its image with the ls -l command (lists directory contents in long format)
    } 
    else if (pid > 0) { // Parent process
        wait(NULL); // The parent waits for the child to finish using wait(), then prints a message once the child has completed its task. 
        printf("Child has finished execution\n");
    }    
    else { // Fork failed
        printf("fork() failed!\n"); // If fork() fails, an error message is printed, and the program exits with a status of 1.
                return 1;
    }

    return 0;
}
```




- **What are the two modes of OSes? Why does an OS need the two modes? How does a process use the two modes?**
  
  Operating systems generally operate in two modes to enhance security and stability: **user mode** and **kernel mode**. These modes define the level of access that running processes have to hardware and memory resources. 
  
  - *User mode*: In user mode, the code being executed has restricted access to hardware resources and cannot directly execute any CPU instruction that could potentially harm the system's stability og security. This mode limimts processes to a subset of the CPU's instructrion set, preventing them from performing operations that could disrupt system operations or other processes. User mde protects the integrity of the OS by preventing user applications from directly accessing critical system resources and hardware
  - *Kernel mode*: Kernel mode provides unrestricted access to the hardware. The code running in this mode can execute any CPU instruction and reference any memory address. Kernel mode is designed for trused functions of the OS like managing memory, running hardware, and handling interrupts. Kernel mode is necessary because certain operations required to manage hardware and resources cannot be performed safely in user mode. It allows the operating system to execute critical tasks that require higher privileges which would be dangerous if exposed to user applications. 

  An OS need the two modes because of:
  
  - *Security and Stability*: OSs use user and kernel mode to enhance security and stability. User mode prevents applications from directly accessing critical system resources, safeguarding the system against malicious activites and errors. Kernel mode is reserved for the OS to perform sensistive tasks that require full access to hardware and system resources.
  - *Control and isolation*: These modes provide controlled isolation, ensuring that faults in user applications do not compromise the core functioning of the system. 

  How a process use the these modes:
  
  - *Normal Operation*: Applications typically run in user mode, handling regular activities without direct access to system hardware or sensitive data. 
  - *System Calls*: When an application needs to perform operations that require privileged access, it makes a system call to temporarily enter kernel mode, where the OS performs the necessary tasks on its behalf. 
  - *Switching modes*: The CPU switches from user mode to kernel mode during system calls or when handling interrupts, then switches back once the task is completed. 


- **What are the two approaches OS can use to switch process?** 
  - *Cooperative Approach*: Relies on processes voluntarily yielding controll of the CPU, typically when they complete a task or are waiting for resources. Simpler one to implement, but risks system stability if a process fails to yield controll, potentially freezing the entire system. 
  - *Preemptive Approach*: Allow the OS to forcibly take control from a running process using a timer interrupt, ensuring that not single process hogs the CPU. Enhances system responsiveness and fairness among processes but requires complex management to handle the frequent interruptions and state saving of processes. 

  Preemptive multitasking is predominant in modern general-purpose operating systems like Windows, macOS, and Linux due to its robustness and ability to efficiently handle multiple processes simultaneously without trusting each process to yield properly. Cooperative multitasking is less common today but can still be found in certain embedded systems and older operating systems where applications are tightly controlled and less complex.


> **Process image** refers to the contents in memory that constitute a running process. Typical elements: user data, user program, stack and process control block  

> **ZOMBIE** is one of many process states. These states depend on their activity and interaction with system resources. The most typical process states are New (Create), Ready, Running, Waiting (Blocked), Suspended, Terminated (Exit) and Zombie.

 

 ## 3. Scheduling



 - **What are *turnaround time*, *waiting time*, and *response time*?**
   
   - *Turnaround time*: Interval of time between the submission of a process and its completion. Includes all the durations for waiting, exection, and any I/O operations. It measures the total time taken for a process to complete its entire cycle, which is critical for assessing overall system performance.
   - *Waiting time*: Refers  to the total time a process spends in the ready queue, waiting for its turn to get the CPU. IOt doesn't include the time spent during execution or I/O operations. Waiting time is a direct measure of how long a process has to wait before its execution begins or resumes, which impacts how users percieve the system's responsiveness.
   - *Response time*: For an interactive process, this is the time from the submission of a request until the response begins to be received. Often a proces can begin producing some output to the user while continuing to process the request. Thus, this is a better measure than TRT from the user's point of view. The scheduling discipline should attempt to achieve low responce time and to maximize the number of interactive users receiving acceptable responce time. 


 - **What is starvation in scheduling algorithms?**
   
   Starvation occurs when a process doesn't receive the necessary resources to proceed with its execution because the scheduling algorithm continuously prioritizes other processes.

 - **What are FIFO, SJF, STCF, RR, MLFQ? What are pros and cons of different scheduling algorithms? Given a job with all needed information, you whould be able to compute *average turnaround time* and *average response time/waiting time* for different SAs**

  This is all examples of scheduling algorithms;

   - *FIFO - First In, First Out*: Jobs are executed in arrival time order.
     - Pros: Simple and fair
     - Cons: Poor for short tasks and I/O intensice tasks
   - *SJF - Shortest Job First*: The job with the shortest execution time is scheduled first.
     - Pros: Good for short tasks
     - Cons: Starvation and requires known execution time for processes.
   - *STCF - Shortest Time-To-Complete First*: Always switch to jobs with the shortest completion time. No preemption.
     - Pros: Preemption and good for short tasks
     - Cons: Starvation and requires known execution time for processes.
   - *RR - Round Robin*: Each process executes for a time slice. Switches to another one regarless whether it has completed its execution or not. If the job has not yet completed it exection, the incomplete job is added to the tail of the ready queue, FIFO queue. 
     - Pros: Fair and good response time
     - Cons: Bad turnaround time
   - *MLFQ - Multi-Level Feedback Queue*: Prioritices processes based on behaviour and needs by moving them between various priority queues based on execution characteristics and history, aiming to optimize both TRT and responsiveness.
     - Pros: Adaptive prioritization, responsiveness and fairness
     - Cons: Complexity and resource intensive

 - **What is the default scheduling algorithm of Linux? How does it work?**

   The default SA of Linxus is called CFS - Completely Fair Scheduler. CFS aims to provide a fair amount of processing time to each running process over measurable periods, using a model where the system tries to distribute CPU time equally among all processes. Instead of maintaining a fixed set of queues for different priorities, CFS uses a red-black tree to manage tasks dynamically, which allows the scheduler to easily select the next runnable task based on its calculated share of the CPU. The key concept of CFS is the use of virtual runtime. which is the amount of time the scheduler percieves a process has been running on the CPU. This mechanism helps to balance the CPU time among all processes, minimizing the waiting time for less CPU-intensive processes and ensuring that heavier processes do not monopolize CPU resources.

> Assumptions: 
> - All jobs arrive at the same time
> - All jobs only use the CPU (no I/O)
> - Run-time of each job is known
> - **Preemption**: Once started, each job runs to completion



## 4. Memory

- **What is the address space of a process? What does an address space of a process usually consist of?**
    
    The address space of a process is the range of memory addresses that it can use to store and manage its data, code, and resources during its execution. Typically, an address space consists of several distinct segments including the code segment, the data segment, the heap, and the stack. Each process in a modern OS has its own unique address space, which isolates it from other processes and prevents direct memory access between them, enhancint the system's stability and security. This structure allows the OS to efficiently manage memory and protect the data integrity of each process.


- **What are virtual address and physical address?**
    Virtual addresses and physical addresses are two different ways of referring to memory locations in computer systems, A virtual address is used by programs running on an OS to access memory, and these addresses are part of a process's address space. Each process sees its own private virtual address space, provided by the OS, which allows the program to operate as ifit has access to a continuous and private memory block. 

    Physical addresses, on the other hand, refer to the actual addresses on the machine's physical memory (RAM). The OS, with the help of the MMU, translates these virtual addresses into physical addresses. This translation is necessary because it allows the OS to use techniques such as paging and swapping to manage memory more efficiently, provide memory protection, and enable processes to use more memory than is physically available on the system.


- **What are static relocation and dynamic relocation? How do they work respectively?**

    Static and dynamic relocation are two methods to manage memory addresses during the process of loading and running programs. 

    - *Static relocation*: Main memory is divided into a number of static partitions at system generation time. A process may be loaded into a partition of equal or greater size. 
      - Pros: Simple to implement, little OS overhead
      - Cons: Inefficient utse of memory due to internal fragmentation,, maximum number of active processes is fixed.

    - *Dynamic relocation*: Partitions are created dynamically, so each process is loaded into a partition of exactly the same size as that process.
      - Pros: No internal fragmentation, more efficient use of main memory
      - Cons: Inefficient use of processor due to the need for compaction to counter external fragmentation.


- **What are the two memory allocation methods when allocating contigous memory space? What are their respective pros and cons?**
   
   The two memory allocation methods are:
    - *Fixed partition*: Memory is divided into a number of fixed-sized partitions, each of which can contain exactly one process.
      - Pros: Simplicity, speed
      - Cons: Internal fragmentation, inflexibility

    - *Variable partition*: Memory is divided into partitions of variable length and size according to the specific needs of each process at the time of allocation.
      - Pros: Efficiency, flexibility
      - Cons: External fragmentation, complexity


- **How do different allocation algorithms, such as FF, BF, and WF, work when allocating memory space?**

   In memory management, different allocation algorithms determine how to allocate blocks of memory to processes efficiently, each with its strategy to manage free memory space. The most common allocation algorithms are First Fit (FF), Best Fit (BF), and Worst Fit (WF). Here's how each works:

    - *First Fit (FF)*: This algorithm allocates the first block of free memory that is large enough to accommodate a process's memory request. It scans memory from the beginning and stops as soon as it finds a suitable space. This method can be faster than others because it doesn't necessarily scan the entire list of free blocks, but it may lead to higher fragmentation over time as it leaves smaller unusable spaces scattered throughout the memory.

    - *Best Fit (BF)*: Best Fit searches through the entire list of free blocks and chooses the smallest block that is sufficient to fulfill the memory request. The goal is to minimize wasted space in the remaining part of the block after allocation. While potentially reducing fragmentation compared to First Fit, Best Fit can be slower, especially in systems with many free memory blocks, as it must search all available blocks before making a decision.

    - *Worst Fit (WF)*: Worst Fit selects the largest available memory block for allocation, aiming to leave the largest possible remainder, thereby reducing the chance of creating unusably small free spaces. This approach can help in maintaining larger chunks of free memory, potentially useful for future large requests. However, like Best Fit, it requires scanning all free blocks, which can be inefficient in terms of time if the list is long.

    Each of these algorithms has its advantages and drawbacks, depending on the specific needs and workload patterns of the system. First Fit is generally quicker but may lead to poor memory utilization over time; Best Fit can optimize memory usage but at the cost of performance; and Worst Fit focuses on keeping larger blocks of memory available, possibly at the expense of leaving too much unused memory in the system.


- **What is segmentation? How does it work?**
   
   Segmentation is a memory management technique that divides a program’s memory into logical units called segments, such as code, data, and stack, which correspond to different parts of the program. Each segment is addressed through a two-part system: a segment number and an offset within that segment. This scheme not only supports logical organization of memory but also enhances security and flexibility by allowing each segment to grow independently and have its own protection settings. Segments are allocated non-contiguous memory spaces, and the system facilitates sharing and protection at the segment level, making memory usage more efficient and tailored to the program's structure.

> **MMU**, Memory Management Unit, is a special hardware to facilitate the translation of virtual addresses to physical addresses.

> **Partitioning** refers to the divison of a computer's main memory into separate sections or partitions that can be individually allocated to different processes running on the system