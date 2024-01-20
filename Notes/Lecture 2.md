### OVERVIEW

- Process concept
- Process state
- Process API (creation, wait)
- Process tree
- Limited directed execution


## PROCESS
- Program is a _static_ entity stored on disk (executable file), process is _active_
  - Program becomes process when executable file loaded into memory
- Execution of program started via GUI mouse clicks, command line entry its name, etc
  - % cat hello.c
- Process is **an abstraction** of CPU
- A program becomes a process when it is selected to execute and loaded into memory.
- A process has an **address space**
![System Call Example](https://diveintosystems.org/book/C13-OS/_images/runprog.png)
> Process: A running program
- Consists of:
  - Code: Instructions
  - Stack: Temp. data, e.g., function parameters, returned addresses, local variables
  - Registers: PC, general purpose, stack pointer
  - Data: Global variables
  - Heap: Dynamically allocated
![System Call Example](https://1480285644-files.gitbook.io/~/files/v0/b/gitbook-legacy-files/o/assets%2F-M13JlZNu0b_edmxHTQk%2F-M4bjWmlwcbXIswV6aVw%2F-M4bjy4gBSfcyAryJi1p%2Fimage.png?alt=media&token=f65768be-4c27-4c03-9552-455484e7b41a)
- A process is represented by a **process controll block (PCB)**
- PCB usually stores relevant information of a single process
  - Process ID (PID, unique)
  - State
  - Parent process
  - Opened files
  - etc.
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

## PROCESS STATE
- Processes transition through various states:
  - READY: Awaiting CPU allocation.
  - RUNNING: Actively executed by the OS.
  - BLOCKED: Suspended due to external events like I/O requests.
  - ZOMBIE: Execution completed but still recorded in the system.
![System Call Example](https://diveintosystems.org/book/C13-OS/_images/procstate.png)

```c
enum procstate {UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE};
```

## PROCESS API 
- Process API to manipulate processes
  - CREATE: Create a new process, e.g., double-click, a command in terminal
  - WAIT: Wait for a process to stop. LigeI/O req
  - DESTROY: Kill the processes
  - STATUS: Obtain the information of a process
  - OTHERS: Suspend or resume a process
 
## PROCESS CREATION
- In Unix-like OSs, a process is created by another process, **parent process** or **calling process**
- In Unix-like OSs, process creation relies on two system calls
  - **fork()**: Create a new process and clone its parent process
  - **exec()**: Overwrite the created process with a new program

## fork()

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

## wait()
- Let the parent process wait for the completion of the child process
  - pid = wait()
- waitpid() is an alternative of wait()

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
## exec()
- Replace current data and code with new in specified file, i.e., it loads a new program into the current process
  -  exec(cmd, argv)
- exec() does not return. It starts to execute the new program. Returns if error.
- There is a family of exec() e.g., execl(), execvp(), etc

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


## WHY fork() + exec()?
- Why don`t we directly create a new process instead of "fork + exec"?
  - Simple and powerful
  - Important to build Unix Shell (an interface to the Unix system)
- Via separating fork() and exec(), we can manipulate various settings just before executing a new program and make the IO redirection and pipe possible
  - IO redirection: % cat w3.c > newfile.txt
  - pipe: % echo hello world | wc


## pipe
- A communication method between two processes
![](https://www.it.uu.se/education/course/homepage/os/vt18/images/module-2/parent-children-pipe.png)


## PROCESS TREE
- % pstree (to show the process tree)
- % ps to (to show all processes)

## LIMITED DIRECT EXECUTION
- The most efficient way to execute a process
  - Direct execution (DE) on CPU
- Problems of DE
  - Restricted Operation
    - Protection
  - Switching between processes
    - Control
- Solution to Restricted Operation
  - Hardware support
  - Different execution modes
- User mode: restricted, limited operations
  - Processes start in user mode
- Kernel mode: privileged, not restricted
  - OS starts in kernel mode
- What if a process wants to perform some restricted operations?
  - System calls: Allow the kernel services to provide some functionalities to user programs
- A process starts in user mode
- If it needs to perform a restricted operation, it calls a system call by executing a trap instruction
- The state and registers of the calling process are stored, the system enters kernel mode, OS completes the syscal work
- Return from syscal, restore the states and registers of the process, and resume the execution of the process.
- Solution to Switching between Processes
  - Cooperative approach
  - Non-cooperative approach
- Cooperative approach
  - Trust process to relinquish CPU to OS through traps
    - System calls
    - Illegal operations, e.g., divided by zero
  - Issue: if no system call
- Non-cooperative approach
  - The OS takes control
  - OS obtains control periodically, e.g., timer interrupter

## SUMMARY 
- In OS, process is a running program and has an address space
- We use process API to create and manage processes
- On Unix-like systems, fork() to duplicate a process, exec() to replace the command
- LDE to execute processes
