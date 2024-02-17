# Sapien Rules
## Sapien does not support:
### Large Memory Returns
1. long
2. vehicle
3. ai
4. point_reference
5. object
6. device

**Your scripts will not execute AT ALL if any of these are a return type. Built in functions are exempt.**

Sapien stack is sensitive to repeated function calls within a single branch. I don't think this applies to built-in scripts.
