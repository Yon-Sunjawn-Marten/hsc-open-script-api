# Sapien Rules
## Sapien does not support:
### Large Working Memory (using these stack returns can overflow)
1. long (risky)
2. vehicle
3. ai
4. point_reference
5. object
6. device

**Your scripts may not execute AT ALL if any of these are a return type. Built in functions are exempt.**

Sapien stack is sensitive to repeated function calls within a single branch. I don't think this applies to built-in scripts.
1. You will get a stack overflow --- siliently --- and the thread will stop executing. Other threads will continue running normally.

### Stubs with parameters (args)
Stub overwrite does not work for scripts with params.
