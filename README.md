# Import

A lightweight alternative to Luau's native require for cases where path traversal becomes a maintainability problem. Instead of resolving paths relative to the calling file's location, Import resolves them relative to your current working directory, the same way fs does, so deeply nested modules no longer need a chain of `../../..` just to reach a shared utility.

## When to use it

- You need to dynamically load modules at runtime where the path isn't known statically
- Your project structure is deep enough that native require paths become fragile

## Limitations to know upfront

- Returns `any`, the Luau type checker cannot statically infer the shape of dynamically loaded modules. You can work around this with a generic type annotation at the call site (`load("./path") :: MyModuleType`), but there is no automatic type inference the way native require provides.

- You're already working heavily with fs and want your module loading to feel consistent with it, since Import resolves paths the same way fs does, you can use `"./"` to point to the project root and traverse from there, rather than thinking about where the require call itself lives

- Not a full drop-in replacement for require. Native require is still the right tool for static, type-safe imports.

**In short:** if you know what you're loading and just need the path resolution to stop fighting you, this does the job.