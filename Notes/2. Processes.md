### PROCESS CONCEPT

#### 1. **Process as an Active Entity**: 
   - **Dynamic Nature**: A program, when loaded into memory and executed, transforms into a process. This transition from a static to an active state is fundamental in understanding the lifecycle of a process.
   - **Execution Initiation**: Processes can be initiated through various user interactions such as clicking on an application icon or entering a command in the terminal.
   - **CPU Abstraction**: The process is a critical abstraction of CPU operation. It represents the CPU's activity and encompasses the execution of sequences of instructions, the current activity, and the process's organization and management of resources.
![System Call Example](https://diveintosystems.org/book/C13-OS/_images/runprog.png)


#### 2. **Process Components**: 
   - **Code Segment**: Contains the executable instructions of the process.
   - **Stack Segment**: Manages function calls, local variables, and return addresses.
   - **Heap Segment**: Area of memory for dynamic allocation.
   - **Data Segment**: Contains global and static variables.
   - **Registers**: Includes the program counter (PC), stack pointer, and general-purpose registers.
![System Call Example](https://1480285644-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-M13JlZNu0b_edmxHTQk%2F-M4bjWmlwcbXIswV6aVw%2F-M4bjy4gBSfcyAryJi1p%2Fimage.png?alt=media&token=f65768be-4c27-4c03-9552-455484e7b41a)

#### 3. **Process Control Block (PCB)**:
   - **PID**: Unique identifier for each process.
   - **Process State**: Indicates the current state (e.g., running, waiting, etc.).
   - **Parent Process Reference**: Information about the parent process.
   - **File Descriptors**: Information about files the process has opened.
   - **Memory Information**: Details about the process's memory allocation.

```c 
struct proc {
      struct spinlock lock; // p->lock must be held when using these:
      enum procstate state; // Process state
      void *chan; // If non-zero, sleeping on chan
      int killed; // If non-zero, have been killed
      int xstate; // Exit status to be returned to parent's wait
      int pid; // Process ID
      // wait_lock must be held when using this:
      struct proc *parent; // Parent process
      // these are private to the process, so p->lock need not be held.
      uint64 kstack; // Virtual address of kernel stack
      uint64 sz; // Size of process memory (bytes)
      pagetable_t pagetable; // User page table
      struct trapframe *trapframe; // data page for trampoline.S
      struct context context; // swtch() here to run process
      struct file *ofile[NOFILE]; // Open files
      struct inode *cwd; // Current directory
      char name[16]; // Process name (debugging)
};
```
### PROCESS STATE

1. **Ready**: The process is prepared to execute and waiting for CPU time.
2. **Running**: The process is currently being executed by the CPU.
3. **Blocked**: The process is not able to execute until certain conditions are met or events occur, commonly I/O operations.
4. **Zombie**: The process has completed execution but still exists in the process table to allow the parent process to read its exit status.

![System Call Example](https://diveintosystems.org/book/C13-OS/_images/procstate.png)

```c
enum procstate {UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE};
```

### PROCESS API

1. **Create**: Initiating a new process instance.
2. **Wait**: Pausing a process until one of its child processes terminates.
3. **Destroy**: Terminating a process.
4. **Status**: Querying the current state or other details of a process.
5. **Control Operations**: Include suspending or resuming a process.

### PROCESS CREATION
- In Unix-like OSs, a process is created by another process, **parent process** or **calling process**
- In Unix-like OSs, process creation relies on two system calls
  - **fork()**: Create a new process and clone its parent process
  - **exec()**: Overwrite the created process with a new program

- **fork()**: 
  - Creates an exact copy of the calling process.
  - Child process receives a copy of the parent's data, code, and stack segments.
  - A function without any arguments
    - pid = fork()
  - Both **parent process** and **child process** continue to execute the instruction following the fork()
  - The return value indicates which process it is (parent or child)
    - Non-zero pid (pid of child process): return value of the parent process
    - Zero: the return value of the new child process
    - -1: an error or failure occurs when creating new process
  - The child process is a duplicate of the parent process and has same
    - instructions
    - data
    - stack
  - Child and parents have different
    - PIDs
    - memory addresses

![](https://www.it.uu.se/education/course/homepage/os/vt18/images/module-2/fork-details.png)


```c
int main(int argc, char *argv[]) {
      printf("hello world (pid:%d)\n", (int) getpid());
      int rc = fork();
      if (rc < 0) {
            // fork failed; exit
            fprintf(stderr, "fork failed\n"); exit(1);
      } 
      else if (rc == 0) {
            // child (new process)
            printf("hello, I am child (pid:%d)\n", (int) getpid());
      }
      else {
            // parent goes down this path (original process)
            printf("hello, I am parent of %d (pid:%d)\n", rc, (int) getpid());
      }

      return 0;

```

- **exec()**: 
  - Allows for running a different program within the process's context.
  - It's a set of system calls (`execvp`, `execl`, etc.) used for various operational needs.
  - Replace current data and code with new in specified file, i.e., it loads a new program into the current process
    -  exec(cmd, argv)
  - exec() does not return. It starts to execute the new program. Returns if error.

![](https://www.it.uu.se/education/course/homepage/os/vt18/images/module-2/exec.png)



```c
int main(int argc, char *argv[]) {
      printf("hello world (pid:%d)\n", (int) getpid());
      int rc = fork();
      if (rc < 0) {
            // fork failed; exit
            fprintf(stderr, "fork failed\n"); exit(1);
      }
      else if (rc == 0) { // child (new process)
            printf("hello, I am child (pid:%d)\n", (int) getpid());
            char *myargs[3];
            myargs[0] = strdup(“wc”); // program: ”wc“ (word count)
            myargs[1] = strdup(“p3.c”); // argument: file to count
            myargs[2] = NULL; // marks end of array
            execvp(myargs[0], myargs); // run word count
            printf(“this will be replaced, so not printed out");
      }
      else { // parent
            int rc_wait = wait(NULL);
            printf(“hello, I am parent of %d (rc_wait:%d) (pid:%d)\n”, rc, rc_wait, (int) getpid());
      }
      return 0;
}
```

### Wait Functionality: Deep Dive

- The `wait()` system call makes a parent process pause its execution until a child process finishes.
- `waitpid()` allows waiting for a specific child process and provides more control over the waiting process.
  
![](https://www.it.uu.se/education/course/homepage/os/vt18/images/module-2/fork-wait-exit.png)

```c
int main(int argc, char *argv[]){
      printf("hello world (pid:%d)\n", (int) getpid());
      int rc = fork();
      if (rc < 0) {
            // fork failed; exit
            fprintf(stderr, "fork failed\n");
            exit(1);
      } 
      else if (rc == 0) {
            // child (new process)
            printf("hello, I am child (pid:%d)\n", (int) getpid());
            sleep(1);
      } 
      else {
            // parent goes down this path (original process)
            int wc = wait(NULL);
            printf("hello, I am parent of %d (wc:%d) (pid:%d)\n", rc, wc, (int) getpid());
      }
      return 0;
}
```

### WHY THE fork() + exec() COMBINATION?

- **Flexibility and Control**: This combination provides a versatile way to create new processes while allowing pre-execution customization (like file descriptor inheritance, process priority adjustments, etc.).
- **Unix Philosophy**: Emphasizes small, modular utilities. The fork-exec model fits well into this philosophy, enabling complex operations to be built from simpler components.
- Why don`t we directly create a new process instead of "fork + exec"?
  - Simple and powerful
  - Important to build Unix Shell (an interface to the Unix system)
- Via separating fork() and exec(), we can manipulate various settings just before executing a new program and make the IO redirection and pipe possible
  - IO redirection: % cat w3.c > newfile.txt
  - pipe: % echo hello world | wc


### LIMITED DIRECT EXECUTION

- **Efficiency**: Direct execution on CPU is the most efficient way for the processor to run a program.
- **Protection and Control**: The main challenges include ensuring that the process doesn't perform harmful operations and managing the CPU resource among multiple processes.
- **Modes of Execution**: 
  - **User Mode**: Limited privileges and restricted operations. Processes start in user mode.
  - **Kernel Mode**: Full privileges, not restricted. OS start in kernel mode.
- **System Calls**: Processes switch to kernel mode to perform privileged operations via system calls.
- **Process Switching**: 
  - **Cooperative Approach**:
    - Trust process to relinquish CPU to OS through traps
      - System calls
      - Illegal operations, e.g., divided by zero
    - Issue: if no system call
  - **Preemptive Approach**:
    - The OS takes control
    - OS obtains control periodically, e.g., timer interrupter
- Solution to Restricted Operation
  - Hardware support
  - Different execution modes
- What if a process wants to perform some restricted operations?
  - System calls: Allow the kernel services to provide some functionalities to user programs
- If it needs to perform a restricted operation, it calls a system call by executing a trap instruction
- The state and registers of the calling process are stored, the system enters kernel mode, OS completes the syscal work
- Return from syscal, restore the states and registers of the process, and resume the execution of the process.


## pipe
- A communication method between two processes
![](https://www.it.uu.se/education/course/homepage/os/vt18/images/module-2/parent-children-pipe.png)


## PROCESS TREE
- % pstree (to show the process tree)
- % ps to (to show all processes)


## SUMMARY 
- In OS, process is a running program and has an address space
- We use process API to create and manage processes
- On Unix-like systems, fork() to duplicate a process, exec() to replace the command
- LDE to execute processes
