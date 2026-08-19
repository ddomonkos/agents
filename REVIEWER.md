# Reviewer guidelines

We strongly care about code correctness, maintainability, simplicity and readability. Correctness is very important, however, some edges cases may not be worthwhile to pursuit if they never occur in real usage and addressing them would be to a significant detriment of code readability or simplicity.

## When reviewing render tests

- Are queries by accessible selectors preferred over `data-testid` selectors (e.g. `getByTestId`)?
