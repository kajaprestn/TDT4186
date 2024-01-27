### SCHEDULING

- **Scheduling** is an important problem in many contexts, e.g., logistics, airports, game schedule, etc.
- **Scheduling:** policies that OS employs to determine the execution order of ready processes
- **Scheduling algorithms/schedulers** have diverse objectives and demonstrate different effects on the system performance
- 

#### TERMINOLOGIES
- Schedulin gmetrics and goals:
    - We want to **maximize**:
        - **CPU utilization:** percentage of time CPU is busy exectuing jobs
        - **Throughput:** the number of processes completed in a given amount of time
        - **Fairness:** all processes are likely to be executed
    - We want to **minimize**:
        - **Turnaround time:** the time elapses between the arrival and completion of a process
            - $T_{t} = T_{c} - T_{a}$
        - **Waiting time:** the time a pricess spends in the ready queue
        - **Response time:*** the time elapses between the process' arrival and its first output


#### ASSUMPTIONS FOR WORKLOADS
- Each job runs for the same amount of time
- All jobs arrive at the same time
- All jobs only use the CPU (no I/O)
- Run-time of each job is known
- Once started, each job runs to completion (Preemption)

#### FIRST IN FIRST OUT (FIFO)
- A simple and bassic scheduling algorithm
- First Come First Served (FCFS)
- Jobs are executed in **arrival time order**

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** |
    |-----|--------------------|----------------|
    | $A$ | $0$ | $10$ |
    | $B$ | $0$ | $10$ |
    | $C$ | $0$ | $10$ |

    A first, B slightly later and then C

- How about FIFO in terms of **turnaround**?
    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** | **Finishing time (_s_)** |
    |-----|--------------------|----------------| ---------------|
    | $A$ | $0$ | $10$ | $10$ |
    | $B$ | $0^{+}$ | $10$ | $20$ |
    | $C$ | $0^{++} $| $10$ | $30$ |

    > $T_{t} = T_{c} - T_{a}$

    > $ A: 10 - 0 = 10$

    > $ B: 20 - 0 = 20$

    > $ C: 30 - 0 = 30$

    > $\text{Average turnaround time} = \frac{10 + 20 + 30}{3} = 20$


    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** |
    |-----|--------------------|----------------|
    | $A$ | $0$ | $70$ |
    | $B$ | $0$ | $10$ |
    | $C$ | $0$ | $10$ |

    Gives an average turnaround time of 80. How can we minimize this?
    
    > $\text{Average turnaround time} = \frac{70 + 80 + 90}{3} = 80$


- The **convoy effect** is a scheduling phenomenon in which a number of jobs wait for one job to get off a core, causing overall device and CPU utilization to be suboptimal

![System Call Example](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRyq0nUxuoDgzPZyW5NTFuIOKRtWNXE_v7rvQ&usqp=CAU)

- Aim to minimize average turnaround time, what is a better scheduling policy for the example above? 

    We take B & C first to get a smaller finishing time, and the AT-time is now reduced.
    
    > $\text{Average turnaround time} = \frac{10 + 20 + 90}{3} = 40$


This way of doing things is called Shortest Job First (SJF)

#### SHORTEST JOB FIRST (SJF)

- Policy: The job with the shortest execution time is scheduled first

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** | **Finishing time (_s_)** |
    |-----|--------------------|----------------| ---------------|
    | $A$ | $0$ | $10$ | $90$ |
    | $B$ | $0^{+}$ | $10$ | $10$ |
    | $C$ | $0^{++} $| $10$ | $20$ |

> Remember the assumptions: 
    >- All jobs arrive at the same time
    >- All jobs only use the CPU (no I/O)
    >- Run-time of each job is known
    >- Once started, each job runs to completion (Preemption)

If the 4 assumptions hold, SJF is an optimal scheduling algorithm in therms of average waiting time, but if B and C arrive after A we'll still get an AT-time of 80 s. Because even though B and C are ready to run at a certain time, it cannot start unless A is finished. The solution is to remove the assumtion of preemption

### SHORTEST TIME-TO-COMPLETE FIRST (STCF)

>- Once started, each job runs to completion (Preemption)

- This assumption indicates the concepts of preemption
- FIFO and SJF are both non-preemptive schedulers
- STCF policy: Always switch to jobs with the shortest completion time
- STCF is a preemptive scheduler
- STCF is optimal in terms of minimizing the average waiting time, if the remaining assumptions hold. 

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** | **Finishing time (_s_)** |
    |-----|--------------------|----------------| ---------------|
    | $A$ | $0$ | $70$ | $90$ |
    | $B$ | $10$ | $10$ | 20$ |
    | $C$ | $20$| $10$ | $30$ |
    > $\text{Average turnaround time} = \frac{90 + 20 + 30}{3} = 47$

- STCF may cause starvation (indefinite blocking)


#### RESPONSE TIME
- Response time is another important performance metric, especially for interactive applications

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** |
    |-----|--------------------|----------------|
    | $A$ | $0$ | $30$ |
    | $B$ | $0^{+}$ | $20$ |
    | $C$ | $0^{++} $| $10$ |

    - FIFO : $ R = \frac{0 + 30 + 50}{3} = 26.7$
    - SJF : $ R = \frac{0 + 10 + 30}{3} = 13.3$

A better scheduler for response time?


#### ROUND-ROBIN (RR)

- A new concept of time quantum/time slice/scheduling quantum: a fixed and small amount of time units
- Each process executes for a time slice
- Switches to another one regardless whether it has completed its execution or not
- If the job har not yet completed its exection, the incomplete job is added to the tail of the ready queue, FIFO queue.

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** |
    |-----|--------------------|----------------|
    | $A$ | $0$ | $30$ |
    | $B$ | $0^{+}$ | $20$ |
    | $C$ | $0^{++} $| $10$ |

- Assume that time slice is 5s
    $R = \frac{0 + 5 + 10}{3} = 5$
- If there are **n** processes in the ready queue and the time slice is **q**, no pricess waits more than **(n-1)q** time units.

    | **Job** | **Arrival time (_s_)** | **Run time (_s_)** | **Time quantum** |
    |-----|--------------------|----------------| ---------------|
    | $A$ | $0$ | $5$ | $1$ |
    | $B$ | $0$ | $5$ |  |
    | $C$ | $0$ | $5$ |  |

    - RR: $ R = \frac{0 + 1 + 2}{3} = 1$
- RR  is a good scheduler in terms of response time...
- but poor in terms of turnaround time
    - FIFO: $ T = \frac{5 + 10 + 15}{3} = 10$
    - SJF: $ T = \frac{5 + 10 + 15}{3} = 10$
    - RR: $ T = \frac{13 + 14 + 15}{3} = 14$
- The selection time of time slice size should be carefully considered (Usually 10-100 milliseconds)
    - Switching between processes come at some overhead, i.e., contect-switch-time
    - Turnaround time depends on the size of time slice. 
- RR is a starvation-free scheduler
    - Some processes never get scheduled, e.g., processes with long execution time in STCF
- RR is fair, simple, and easy to implement and thus is used in modern OSs, such as Linux and MacOS. 
- XV6 implements a simple RR.


#### IMPACT OF CONTEXT SWITCHING
- **Context Switching**: Involves the OS storing and restoring the state (context) of a process or thread, so that execution can be resumed from the same point later.
- **Performance Impact**: Frequent context switching can lead to increased overhead, reducing CPU efficiency. This is particularly evident in algorithms like Round Robin, where the time slice is very short.
- **Balancing Act**: An optimal scheduling algorithm seeks to balance the need for context switching (to ensure fairness and responsiveness) with the overhead it introduces.

#### ADVANCED SCHEDULING CONCEPTS 
- **Dynamic Priority Scheduling**: Priorities of tasks are dynamically adjusted, often used in real-time systems.
- **Multi-Level Queue Scheduling**: Involves multiple queues for processes with different priority levels, allowing more granular control.
- **Real-Time Scheduling**: Ensures that critical real-time processes receive CPU time in a predictable manner, crucial in systems where timing is critical.

#### PRACTICAL CHALLENGES
- **Predicting Job Length**: Algorithms like SJF require prior knowledge of job lengths, which is often impractical.
- **Starvation**: Lower priority jobs in SJF or STCF may experience indefinite delays, known as starvation.
- **Complexity in Dynamic Systems**: Implementing sophisticated algorithms like STCF or dynamic priority scheduling can be complex in systems with varied and unpredictable workloads.


#### OVERVIEW
    
| **Algorithm** | **Pros** | **Cons** |
|-----|--------------------|----------------|
| FCFS/FIFO | Simple fairness  | Poor for short tasks |
|  | Fairness | Poor for I/O intensive tasks |
| SJF | Good for short tasks | Starvation |
|  |  | Known execution time |
| STCF | Good for short tasks | Starvation |
|  | Preemption | Known execution time |
| RR| Response time | Turnaround time |
| | Fairness |  |

| **Algorithm** | **Average Turnaround Time** | **Complexity** | **Context Switch Overhead** | **Best Use Case**           | **Limitations**       |
|---------------|-----------------------------|----------------|-----------------------------|-----------------------------|-----------------------|
| FCFS/FIFO     | Varies                      | Low            | Low                         | Simple, sequential tasks    | Poor for short tasks  |
| SJF           | Optimal for known durations | Moderate       | Low                         | Short, predictable tasks    | Starvation; requires knowing job durations in advance |
| STCF          | Optimal if preemption allowed | High         | Moderate to High            | Dynamic, varied-length tasks | Starvation; complex to implement |
| RR            | High for short time slices  | Moderate       | High                        | Interactive, time-sharing systems | Inefficient for long tasks; depends on time slice size |

#### XV6 SCHEDULER
- Scheduler is implemented as an individual kernel thread
    - To schedule a new task, it needs to first switch the scheduler thread
- Two functions
    - **sched()**
        - Check the various conditions in **yield()**, **exit()**, and **sleep()**
        - Hand the controll over to the scheduler function
    - **scheduler()**
        - Select a runnable process to execute
        - Per-CPU core thread. i.e., each CPU has one scheduler
- Context-switch
    - **swtch(struct contect \*old, struct contect \*new)**
        - Save the old context and load the new context

#### SUMMARY
- There are different metrics to evaluate the performance of scheduling algorithms
- FIFO is a simple scheduler, but suffers from the convoy effect. 
- SJF is an optimal scheduling algorithm in terms of minimizing average waiting time, if all jobs start simultaneously and know their execution time in prior.
- STCF is an optimal scheduling algorithm in terms of minimizing average turnaround time, if all jobs know thes execution times in prior. 
- RR is a better algorithm in terms of minimizing average response time. 

In conclusion, scheduling algorithms play a critical role in optimizing CPU utilization and system performance. While algorithms like FIFO are simple and fair, they might not be efficient for systems with varied job lengths. SJF and STCF provide optimal solutions for certain conditions but face challenges like starvation and the need for job length prediction. Round Robin offers fairness and responsiveness at the expense of turnaround time. Advanced scheduling concepts attempt to address these limitations but introduce complexity. The choice of a scheduling algorithm depends on the specific requirements and constraints of the system in question.


