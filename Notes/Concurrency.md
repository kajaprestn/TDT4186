### CONCURRENCY

#### OUTLINES
- Motivation
- Thread
- Concurrency

#### MOTIVATION
- CPU: Low frequency, but multiple/many cores
- Goal: Write applications that fulle utilize may cores
- Abstraction: Process
- Build applications using communicating process
- Example: Chrome (process pr tab)
- Pros: No need for new abstractions; isolation
- Cons:
    - Cumbersome programming
    - High communication overheads
    - Expensive context switching (why expensive?)
- Inter-process communication